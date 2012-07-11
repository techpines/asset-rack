
crypto = require 'crypto'
async = require 'async'
pathutil = require 'path'
knox = require 'knox'
EventEmitter = require('events').EventEmitter

class exports.AssetPackage extends EventEmitter
    constructor: (@options) ->
        super()
        for key, value of @options
            this[key] = value
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()
        @assets = @getAssets() if @getAssets?
        @create() if @assets?

    create: -> process.nextTick =>
        async.forEach @assets, (asset, next) ->
            asset.on 'complete', ->
                next()
            asset.create()
        , (error) =>
            return @emit 'error', error if error?
            @completed = true
            @emit 'complete'

    getConfig: ->
        config = for asset in @assets
            url: asset.url
            md5: asset.md5
            specificUrl: asset.specificUrl
            mimetype: asset.mimetype

    handle: (request, response, next) ->
        response.local 'assets', this
        asset = @getAsset request.url
        return next() unless asset?
        response.header 'Content-Type', asset.mimetype
        #response.header 'Cache-Control', "public, max-age=#{@options.maxAge}"
        response.send asset.contents

    addPackage: (pack) ->
        @assets = @assets.concat pack.assets

    getAsset: (specificUrl) ->
        for asset in @assets
            if asset.specificUrl is specificUrl
                return asset

    pushS3: (options) ->
        async.forEach @assets, (asset, next) =>
            client = knox.createClient options
            url = asset.specificUrl.slice 1, asset.specificUrl.length
            request = client.put url, {
                'Content-Length': asset.contents.length
                'Content-Type': asset.mimetype
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
                
            request.end asset.contents
        , =>
            @emit 's3-upload-complete'
    
    tag: (url) ->
        for asset in @assets
            return asset.tag() if url is asset.url
        throw new Error "No asset found for url: #{url}"
            
class exports.Asset extends EventEmitter
    mimetype: 'text/plain'
    constructor: (@options) ->
        @url = @options.url
        @hash = if @options.hash? then @options.hash else true
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()
        @on 'complete', @createSpecificUrl
        super()
    create: ->
        @emit 'complete'
    tag: ->
        switch @mimetype
            when 'application/javascript'
                tag = "<script type=\"#{@mimetype}\" "
                return tag += "src=\"#{@specificUrl}\"></script>"
            when 'text/css'
                return "<link rel=\"stylesheet\" href=\"#{@specificUrl}\">"
    createSpecificUrl: ->
        @md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        unless @hash
            return @specificUrl = @url
        @ext = pathutil.extname @url
        @specificUrl = @url.replace new RegExp("#{@ext}"), "-#{@md5}#{@ext}"
        if @hostname?
            @specificUrl = "//#{@hostname}#{@specificUrl}"
        @completed = true

exports.LessAsset = require('./assets/less').LessAsset
exports.BrowserifyAsset = require('./assets/browserify').BrowserifyAsset
exports.JadeAsset = require('./assets/jade').JadeAsset
exports.StaticAssetPackage = require('./assets/static').StaticAssetPackage
exports.StaticAsset = require('./assets/static').StaticAsset

