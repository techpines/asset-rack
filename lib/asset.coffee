
# Asset.coffee - The Asset class is the core abstraction for the framework

# Pull in our dependencies
async = require 'async'
crypto = require 'crypto'
pathutil = require 'path'
fs = require 'fs'
zlib = require 'zlib'
mime = require 'mime'
{extend} = require './util'
{EventEmitter} = require 'events'
Rack = require('./rack').Rack

# IE8 Compatibility
mime.types.js = 'text/javascript'
mime.extensions['text/javascript'] = 'js'

# Asset class handles compilation and a lot of other functionality
class exports.Asset extends EventEmitter

    # Default max age is set to one year
    defaultMaxAge: 60*60*24*365

    constructor: (options) ->
        super()
        options ?= {}

        # Set the url
        @url = options.url if options.url?
        @hostname = options.hostname if options.hostname?

        # Set the cotents if given
        @contents = options.contents if options.contents?

        # Set headers if given
        @headers = if options.headers then options.headers else {}
        headers = {}
        for key, value of @headers
            headers[key.toLowerCase()] = value
        @headers = headers

        # Get the extension from the url
        @ext = pathutil.extname @url

        # Set whether to watch or not
        @watch = options.watch
        @watch ?= false

        # Set the correct mimetype
        @mimetype = options.mimetype if options.mimetype?
        @mimetype ?= mime.types[@ext.slice(1, @ext.length)]
        @mimetype ?= 'text/plain'

        # Whether to gzip the asset or not
        @gzip = options.gzip

        # Whether to hash the url or not or both
        @hash = options.hash if options.hash?

        # Max age for HTTP cache control
        @maxAge = options.maxAge if options.maxAge?

        # Whether to allow caching of non-hashed urls
        @allowNoHashCache = options.allowNoHashCache if options.allowNoHashCache?

        # Fire callback if someone listens for a "complete" event
        # and it has already been called
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()

        # This event is triggered after the contents have been created
        @on 'created', (data) =>

            # If content then it's a single asset
            if data?.contents?
                @contents = data.contents

            # If assets then it's a mutil asset
            if data?.assets?
                @assets = data.assets

            # If this is a single asset then do some post processing
            if @contents?
                @createSpecificUrl()
                @createHeaders()


            # If it's a muti asset then make sure they are all completed
            if @assets?
                async.forEach @assets, (asset, done) ->
                    asset.on 'error', done
                    asset.on 'complete', done
                , (error) =>
                    return @emit 'error', error if error?
                    @completed = true
                    @emit 'complete'
            else
                # can't mark "@completed" yet, since mutli-assets containing this asset
                # may get the "complete" callback twice
                # see: https://github.com/techpines/asset-rack/pull/96
                # @completed = true

                # Handles gzipping
                if not @gzip and Rack.gzippableUrl?
                    if Rack.gzippableUrl(@url)
                        @gzip = true

                if @gzip
                    zlib.gzip @contents, (error, gzip) =>
                        @completed = true
                        console.log "gzip failed failed for #{@url}: #{error}" if error?
                        return @emit 'error', error if error?
                        @gzipContents = gzip
                        # set gzip header
                        @headers['content-encoding'] ?= 'gzip'
                        @emit 'complete'
                else
                    @completed = true
                    @emit 'complete'

            # Does the file watching
            if @watch
                @toWatch = if Array.isArray @toWatch then @toWatch else [@toWatch]
                @toWatch.forEach (path) =>
                    this[path] = fs.watch path, (event, filename) =>
                        if event is 'change'
                            console.log filename, 'changed'
                            this[path].close()
                            @completed = false
                            @assets = false
                            process.nextTick =>
                                @emit 'start'

        # Listen for errors and throw if no listeners
        @on 'error', (error) =>
            throw error if @listeners('error') is 1
        @on 'start', =>
            @maxAge ?= @rack?.maxAge
            @maxAge ?= @defaultMaxAge unless @hash is false
            @allowNoHashCache ?= @rack?.allowNoHashCache
            @create options

        # Next tick because we need to wait on a possible rack
        process.nextTick =>

            # Setting max age for HTTP cache control
            @maxAge ?= @defaultMaxAge

            # Create the asset unless it is part of a rack
            # then the rack will trigger the "start" event
            return @create options unless @rack?

    # Add an asset for multi asset support
    addAsset: (asset) ->
        @assets = [] unless @assets?
        @assets.push asset

    # Responds to an express route
    respond: (request, response) ->
        headers = {}
        if request.path is @url and @allowNoHashCache isnt true
            for key, value of @headers
                headers[key] = value
            delete headers['cache-control']
        else
            headers = @headers
        for key, value of headers
            response.header key, value
        if @gzip
            response.send @gzipContents
        else response.send @contents

    # Check if a given url "matches" this asset
    checkUrl: (url) ->
        return true if url is @specificUrl
        return true if (not @isHashed? and url is @url.replace(/^https?:\/\/[^\/]+\//, '/'))
        if @specificUrl and not @domainlessSpecificUrl
          @domainlessSpecificUrl = @specificUrl.replace(/^https?:\/\/[^\/]+\//, '/')
        return true if url is @domainlessSpecificUrl

    # Used so that an asset can be express middleware
    handle: (request, response, next) ->
        handle = =>
            if @assets?
                for asset in @assets
                    if asset.checkUrl request.path
                        return asset.respond request, response
            if @checkUrl(request.path)
                @respond request, response
            else next()
        if @completed is true
            handle()
        else @on 'complete', ->
            handle()

    # Default create method, usually overwritten
    create: (options) ->

        # At the end of a create method you always call
        # the created event
        @emit 'created'

    # Create the headers for an asset
    createHeaders: ->
        @headers['content-type'] ?= "#{@mimetype}"
        if @gzip
            @headers['content-encoding'] ?= 'gzip'
        if @maxAge?
            @headers['cache-control'] ?= "public, max-age=#{@maxAge}"

    # Gets the HTML tag for an asset
    tag: ->
        switch @mimetype
            when 'text/javascript'
                tag = "\n<script type=\"#{@mimetype}\" "
                return tag += "src=\"#{@specificUrl}\"></script>"
            when 'text/css'
                return "\n<link rel=\"stylesheet\" href=\"#{@specificUrl}\">"

    getUploadUrl: ->
        url = @specificUrl
        if (url.indexOf('//') >= 0)
            url = url.replace(/^[^\/]*\/\/[^\/]+\//, '')
        if (url.slice(0, 1) == '/')
            url = url.slice 1
        url

    # Creates and md5 hash of the url for caching
    createSpecificUrl: ->

        # This is the no hash option
        shouldHash = @hash isnt false
        if shouldHash and Rack.neverHashThis?
            if Rack.neverHashThis(@url)
              shouldHash = false
              # console.log('hashing for this url is disabled: ' + @url)

        if not shouldHash
            @useDefaultMaxAge = false
            return @specificUrl = @url

        @md5 = crypto.createHash('md5').update(@contents).digest 'hex'

        # Construction of the hashed url
        @specificUrl = "#{@url.slice(0, @url.length - @ext.length)}-#{@md5}#{@ext}"
        @isHashed = true
        # Might need a hostname if not on same server
        if @hostname?
            @specificUrl = "//#{@hostname}#{@specificUrl}"


    # For extending this class in javascript
    # for coffeescript you can use the builtin extends
    @extend: extend
