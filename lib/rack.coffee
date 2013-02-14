
async = require 'async'
pkgcloud = require 'pkgcloud'
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
                stream = new BufferStream asset.contents
                url = asset.specificUrl.slice 1, asset.specificUrl.length
                headers = {}
                for key, value of asset.headers
                    headers[key] = value
                headers['x-amz-acl'] = 'public-read' if options.provider is 'amazon'
                options =
                    container: options.container
                    remote: url
                    headers: headers
                    stream: stream
                client.upload options, (error) ->
                    return next error if error?
                    next()
            , (error) ->
                if error?
                    return next error if next?
                    throw error
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
