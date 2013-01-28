
crypto = require 'crypto'
async = require 'async'
pathutil = require 'path'
knox = require 'knox'
EventEmitter = require('events').EventEmitter

class exports.AssetRack extends EventEmitter
    constructor: (@assetObjects, @options) ->
        super()
        @maxAge = @options.maxAge
        @assets = []
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()
        @create()

    create: -> process.nextTick =>
        async.forEachSeries @assetObjects, (asset, next) =>
            asset.on 'complete', =>
                if asset instanceof exports.Asset
                    @assets.push asset
                else
                    @assets = @assets.concat asset.assets
                next()
            asset.rack = @
            asset.create()
        , (error) =>
            return @emit 'error', error if error?
            for asset in @assets
                asset.maxAge ?= @maxAge
            @completed = true
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
        asset = @getAsset request.url
        return next() unless asset?
        response.header 'Content-Type', asset.mimetype
        if asset.maxAge?
            response.header 'Cache-Control', "public, max-age=#{asset.maxAge}"
        response.send asset.contents

    getAsset: (specificUrl) ->
        for asset in @assets
            if asset.specificUrl is specificUrl
                return asset

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
            return asset.tag() if url is asset.url
        throw new Error "No asset found for url: #{url}"

    url: (url) ->
        for asset in @assets
            return asset.specificUrl if url is asset.url

class exports.Asset extends EventEmitter
    mimetype: 'text/plain'
    defaultMaxAge: 60*60*24*365 # one year
    constructor: (@options) ->
        @url = @options.url
        @hash = @options.hash
        @maxAge = @options.maxAge
        @maxAge ?= @defaultMaxAge
        @allowNoHashCache = @options.allowNoHashCache
        @ext = pathutil.extname @url
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()
        @on 'complete', =>
            @completed = true
            @createSpecificUrl()
        @create()
        super()

    handle: (request, response, next) ->
        isUrlMatch = request.url is @specificUrl or (not @hash? and request.url is @url)
        if isUrlMatch or (not @completed and @isRelevantUrl(request.url))
            if @completed
                response.header 'Content-Type', @mimetype
                test =  @maxAge? and (request.url isnt @url or @allowNoHashCache is true)
                if test
                    response.header 'Cache-Control', "public, max-age=#{@maxAge}"
                return response.send @contents
            else return @on 'complete', =>
                response.header 'Content-Type', @mimetype
                test = @maxAge? and (request.url isnt @url or @allowNoHashCache is true)
                if test
                    response.header 'Cache-Control', "public, max-age=#{@maxAge}"
                return response.send @contents
        next()
        
    create: ->
        @contents = 'asset-rack'
        @emit 'complete'

    tag: ->
        switch @mimetype
            when 'text/javascript'
                tag = "\n<script type=\"#{@mimetype}\" "
                return tag += "src=\"#{@specificUrl}\"></script>"
            when 'text/css'
                return "\n<link rel=\"stylesheet\" href=\"#{@specificUrl}\">"
    createSpecificUrl: ->
        @md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        if @hash is false
            @useDefaultMaxAge = false
            return @specificUrl = @url
        @specificUrl = "#{@url.slice(0, @url.length - @ext.length)}-#{@md5}#{@ext}"
        if @hostname?
            @specificUrl = "//#{@hostname}#{@specificUrl}"
        
    isRelevantUrl: (specificUrl) ->
        baseUrl = @url.slice(0, @url.length - @ext.length)
        if specificUrl.indexOf baseUrl isnt -1 and @ext is pathutil.extname specificUrl
            return true
        return false
            
exports.LessAsset = require('./assets/less').LessAsset
exports.StylusAsset = require('./assets/stylus').StylusAsset
exports.SassAsset = require('./assets/sass').SassAsset
exports.BrowserifyAsset = require('./assets/browserify').BrowserifyAsset
exports.JadeAsset = require('./assets/templates').JadeAsset
exports.StaticAssetBuilder = require('./assets/static').StaticAssetBuilder
exports.SnocketsAsset = require('./assets/snockets').SnocketsAsset
exports.AngularTemplatesAsset = require('./assets/angular-templates').AngularTemplatesAsset
