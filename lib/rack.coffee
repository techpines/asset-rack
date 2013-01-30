
async = require 'async'
knox = require 'knox'
{EventEmitter} = require 'events'


class exports.AssetRack extends EventEmitter
    constructor: (assets, options) ->
        super()
        options ?= {}
        @maxAge = options.maxAge
        @allowNoHashCache = options.allowNoHashCache
        @on 'complete', => @completed = true
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
                if asset.contents
                    @assets.push asset
                if asset.assets
                    @assets.concat asset.assets
                next()
            asset.rack = this
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

    handle: (request, response, next) ->
        response.locals assets: this
        @on 'complete', =>
            for asset in @assets
                check = asset.checkUrl request.url
                return asset.respond request, response if check
            return next() unless asset?

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
            return asset.tag() if asset.checkUrl url
        throw new Error "No asset found for url: #{url}"

    url: (url) ->
        for asset in @assets
            return asset.specificUrl if url is asset.checkUrl url
