
crypto = require 'crypto'
async = require 'async'
pathutil = require 'path'
knox = require 'knox'
EventEmitter = require('events').EventEmitter

class exports.AssetPackage extends EventEmitter
    constructor: (@options) ->
        super()
        @config = @options.config
        @assets = @options.assets
        @hostname = @options.hostname
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()
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
        args = Array.prototype.slice.call arguments, 1
        asset = @assetMapping[url]
        throw new Error "No asset found for url: #{url}" unless asset?
        return asset.tag.apply asset, @options.hostname, args
            
class exports.Asset extends EventEmitter
    mimetype: 'text/plain'
    constructor: (@options) ->
        @url = @options.url
        @on 'complete', @createSpecificUrl
        super()
    create: ->
        @emit 'complete'
    tag: ->
        switch @mimetype
            when 'application/javascript'
                tag = "<script type=\"#{@mimtype}\" "
                return tag += "src=\"#{@specificUrl}\"><script>"
            when 'text/css'
                return "<link rel=\"stylesheet\" href=\"#{@specificUrl}\">"
    createSpecificUrl: ->
        @md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        @ext = pathutil.extname @url
        @specificUrl = @url.replace new RegExp("#{@ext}"), "-#{@md5}#{@ext}"
        if @hostname?
            @specificUrl = "//#{@hostname}#{@specificUrl}"

exports.LessAsset = require('./assets/less').LessAsset
exports.BrowserifyAsset = require('./assets/browserify').BrowserifyAsset
exports.JadeAsset = require('./assets/jade').JadeAsset


