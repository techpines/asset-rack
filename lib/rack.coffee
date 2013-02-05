
async = require 'async'
knox = require 'knox'
pkgcloud = require 'pkgcloud'
BufferStream = require('./util').BufferStream
ClientRack = require('./.').ClientRack
{EventEmitter} = require 'events'

class exports.AssetRack extends EventEmitter
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

    getConfig: ->
        config = for asset in @assets
            url: asset.url
            md5: asset.md5
            specificUrl: asset.specificUrl
            mimetype: asset.mimetype
            maxAge: asset.maxAge
            hash: asset.hash

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
        else @once 'complete', handle

    deploy: (options, next) ->
        client = pkgcloud.storage.createClient options
        console.log @assets.length
        async.forEachSeries @assets, (asset, next) =>
            stream = new BufferStream asset.contents
            console.log stream
            url = asset.specificUrl.slice 1, asset.specificUrl.length
            client.upload
                container: options.container
                remote: url
                headers: asset.headers
                stream: stream
            , (error) ->
                console.log 'upload called my callback'
                return next error if error?
                next()
        , (error) ->
            return next error if error?
            next()

    pushS3: (options) ->
        async.forEachSeries @assets, (asset, next) =>
            buffer = new Buffer asset.contents
            client = knox.createClient options
            url = asset.specificUrl.slice 1, asset.specificUrl.length
            request = client.put url, {
                'Content-Length': buffer.length
                'Content-Type': asset.mimetype
                'Cache-Control': "public, max-age=#{asset.maxAge}"
                'x-amz-acl': 'public-read'
            }
            request.on 'response', (response) =>
                response.setEncoding 'utf8'
                if response.statusCode is 200
                    next()
                else
                    message = "#{asset.url}: Bad S3 status code response #{response.statusCode}"
                    @emit 'error', new Error message
            request.on 'error', (error) =>
                @emit 'error', error

            request.end buffer
        , =>
            @emit 's3-upload-complete'

    tag: (url) ->
        for asset in @assets
            return asset.tag() if asset.url is url
        throw new Error "No asset found for url: #{url}"

    url: (url) ->
        for asset in @assets
            return asset.specificUrl if url is asset.url
