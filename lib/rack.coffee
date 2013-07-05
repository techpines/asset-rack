
# Rack.coffee - A Rack is an asset manager

# Pull in our dependencies
async = require 'async'
pkgcloud = require 'pkgcloud'
fs = require 'fs'
jade = require 'jade'
pathutil = require 'path'
{BufferStream, extend} = require('./util')
{EventEmitter} = require 'events'

# Rack - Manages multiple assets
class exports.Rack extends EventEmitter
    constructor: (assets, options) ->
        super()

        # Set a default options object
        options ?= {}

        # Max age for HTTP Cache-Control
        @maxAge = options.maxAge

        # Allow non-hahshed urls to be cached
        @allowNoHashCache = options.allowNoHashCache

        # Once complete always set the completed flag
        @on 'complete', =>
            @completed = true

        # If someone listens for the "complete" event
        # check if it's already been called
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()

        # Listen for the error event, throw if no listeners
        @on 'error', (error) =>
            console.log error
            @hasError = true
            @currentError = error

        # Give assets in the rack a reference to the rack
        for asset in assets
            asset.rack = this

        # Create a flattened array of assets
        @assets = []
    
        # Do this in series for dependency conflicts
        async.forEachSeries assets, (asset, next) =>

            # Listen for any asset error events
            asset.on 'error', (error) =>
                next error

            # Wait for assets to finish completing
            asset.on 'complete', =>

                # This is necessary because of asset recompilation
                return if @completed
        
                # If the asset has contents, it's a single asset
                if asset.contents?
                    @assets.push asset
                
                # If it has assets, then it's multi-asset
                if asset.assets?
                    @assets = @assets.concat asset.assets
                next()
    
            # This tells our asset to start
            asset.emit 'start'

        # Handle any errors for the assets
        , (error) =>
            return @emit 'error', error if error?
            @emit 'complete'
        
    # Makes the rack function as express middleware
    handle: (request, response, next) ->
        response.locals assets: this
        if request.url.slice(0,11) is '/asset-rack'
            return @handleAdmin request, response, next
        if @hasError
            for asset in @assets
                check = asset.checkUrl request.path
                return asset.respond request, response if check
            return response.redirect '/asset-rack/error'
        handle = =>
            for asset in @assets
                check = asset.checkUrl request.path
                return asset.respond request, response if check
            next()
        if @completed
            handle()
        else @on 'complete', handle

    handleError: (request, response, next) ->
        # No admin in production for now
        return next() if process.env.NODE_ENV is 'production'
        errorPath = pathutil.join __dirname, 'admin/templates/error.jade'
        fs.readFile errorPath, 'utf8', (error, contents) =>
            return next error if error?
            compiled = jade.compile contents,
                filename: errorPath
            response.send compiled
                stack: @currentError.stack.split '\n'

    handleAdmin: (request, response, next) ->
        # No admin in production for now
        return next() if process.env.NODE_ENV is 'production'
        split = request.url.split('/')
        if split.length > 2
            path = request.url.replace '/asset-rack/', ''
            if path is 'error'
                return @handleError request, response, next
            response.sendfile pathutil.join __dirname, 'admin', path
        else
            adminPath = pathutil.join __dirname, 'admin/templates/admin.jade'
            fs.readFile adminPath, 'utf8', (error, contents) =>
                return next error if error?
                compiled = jade.compile contents,
                    filename: adminPath
                response.send compiled
                    assets: @assets

    # Writes a config file of urls to hashed urls for CDN use
    writeConfigFile: (filename) ->
        config = {}
        for asset in @assets
            config[asset.url] = asset.specificUrl
        fs.writeFileSync filename, JSON.stringify(config)

    # Deploy assets to a CDN
    deploy: (options, next) ->
        options.keyId = options.accessKey
        options.key = options.secretKey
        deploy = =>
            client = pkgcloud.storage.createClient options
            assets = @assets
            # Big time hack for rackspace, first asset doesn't upload, very strange.
            # Might be bug with pkgcloud.  This hack just uploads the first file again
            # at the end.
            assets = @assets.concat @assets[0] if options.provider is 'rackspace'
            async.forEachSeries assets, (asset, next) =>
                stream = null
                headers = {}
                if asset.gzip
                    stream = new BufferStream asset.gzipContents
                    headers['content-encoding'] = 'gzip'
                else
                    stream = new BufferStream asset.contents
                url = asset.specificUrl.slice 1, asset.specificUrl.length
                for key, value of asset.headers
                    headers[key] = value
                headers['x-amz-acl'] = 'public-read' if options.provider is 'amazon'
                clientOptions =
                    container: options.container
                    remote: url
                    headers: headers
                    stream: stream
                client.upload clientOptions, (error) ->
                    return next error if error?
                    next()
            , (error) =>
                if error?
                    return next error if next?
                    throw error
                if options.configFile?
                    @writeConfigFile options.configFile
                next() if next?
        if @completed
            deploy()
        else @on 'complete', deploy

    # Creates an HTML tag for a given asset
    tag: (url) ->
        for asset in @assets
            return asset.tag() if asset.url is url
        throw new Error "No asset found for url: #{url}"

    # Gets the hashed url for a given url
    url: (url) ->
        for asset in @assets
            return asset.specificUrl if url is asset.url

    # Extend the class for javascript 
    @extend: extend

# The ConfigRack uses a json file and a hostname to map assets to a url
# without actually compiling them
class ConfigRack
    constructor: (options) ->
        # Check for required options
        throw new Error('options.configFile is required') unless options.configFile?
        throw new Error('options.hostname is required') unless options.hostname?
    
        # Setup our options
        @assetMap = require options.configFile
        @hostname = options.hostname
        
    # For hooking up as express middleware
    handle: (request, response, next) ->
        response.locals assets: this
        for url, specificUrl of @assetMap
            if request.path is url or request.path is specificUrl

                # Redirect to the CDN, the config does not have the files
                return response.redirect "//#{@hostname}#{specificUrl}"
        next()
    
    # Simple function to get the tag for a url
    tag: (url) ->
        switch pathutil.extname(url)
            when '.js'
                tag = "\n<script type=\"text/javascript\" "
                return tag += "src=\"//#{@hostname}#{@assetMap[url]}\"></script>"
            when '.css'
                return "\n<link rel=\"stylesheet\" href=\"//#{@hostname}#{@assetMap[url]}\">"

    # Get the hashed url for a given url
    url: (url) ->
        return "//#{@hostname}#{@assetMap[url]}"
        
        
# Shortcut function
exports.fromConfigFile = (options) ->
    return new ConfigRack(options)
