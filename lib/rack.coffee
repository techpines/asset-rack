
async = require 'async'
pkgcloud = require 'pkgcloud'
fs = require 'fs'
pathutil = require 'path'
{BufferStream, extend} = require('./util')
ClientRack = require('./.').ClientRack
{EventEmitter} = require 'events'

class exports.Rack extends EventEmitter
    constructor: (assets, options) ->
        super()
        options ?= {}
        @maxAge = options.maxAge
        @allowNoHashCache = options.allowNoHashCache
        @on 'complete', =>
            @completed = true
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()
        @on 'error', (error) =>
            throw error if @listeners('error').length is 1
        for asset in assets
            asset.rack = this
        @assets = []
        async.forEachSeries assets, (asset, next) =>
            asset.on 'error', (error) =>
                next error
            asset.on 'complete', =>
                if asset.contents?
                    @assets.push asset
                if asset.assets?
                    @assets = @assets.concat asset.assets
                next()
            asset.rack = this
            asset.emit 'start'
        , (error) =>
            return @emit 'error', error if error?
            @emit 'complete'

    createClientRack: ->
        clientRack =  new ClientRack
        clientRack.rack = this
        clientRack.emit 'start'
        clientRack
    
    addClientRack: (next) ->
        clientRack = @createClientRack()
        clientRack.on 'complete', =>
            @assets.push clientRack
            next()
        
    handle: (request, response, next) ->
        response.locals assets: this
        handle = =>
            for asset in @assets
                check = asset.checkUrl request.url
                return asset.respond request, response if check
            next()
        if @completed
            handle()
        else @on 'complete', handle

    writeConfigFile: (filename) ->
        config = {}
        for asset in @assets
            config[asset.url] = asset.specificUrl
        fs.writeFileSync filename, JSON.stringify(config)

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
                console.log asset.url
                stream = null
                if asset.gzip
                    stream = new BufferStream asset.gzipContents
                else
                    stream = new BufferStream asset.contents
                url = asset.specificUrl.slice 1, asset.specificUrl.length
                headers = {}
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

    tag: (url) ->
        for asset in @assets
            return asset.tag() if asset.url is url
        throw new Error "No asset found for url: #{url}"

    url: (url) ->
        for asset in @assets
            return asset.specificUrl if url is asset.url

    @extend: extend

class ConfigRack
    constructor: (options) ->
        throw new Error('options.configFile is required') unless options.configFile?
        throw new Error('options.hostname is required') unless options.hostname?
        @assetMap = require options.configFile
        @hostname = options.hostname
        
    handle: (request, response, next) ->
        response.locals assets: this
        for url, specificUrl of @assetMap
            if request.url is url or request.url is specificUrl
                return response.redirect "//#{@hostname}#{specificUrl}"
        next()
    tag: (url) ->
        switch pathutil.extname(url)
            when '.js'
                tag = "\n<script type=\"text/javascript\" "
                return tag += "src=\"//#{@hostname}#{@assetMap[url]}\"></script>"
            when '.css'
                return "\n<link rel=\"stylesheet\" href=\"//#{@hostname}#{@assetMap[url]}\">"
    url: (url) ->
        return "//#{@hostname}#{@assetMap[url]}"
        
        
exports.fromConfigFile = (options) ->
    return new ConfigRack(options)
