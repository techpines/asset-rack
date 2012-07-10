
crypto = require 'crypto'
async = require 'async'
pathutil = require 'path'
EventEmitter = require('events').EventEmitter

class exports.AssetPackage extends EventEmitter
    constructor: (@options) ->
        @config = @options.config
        @assets = @options.assets
        @hostname = @options.hostname
        @create() if @assets?
        super()

    create: ->
        console.log 'we creating package'
        async.forEach @assets, (asset, next) ->
            asset.create()
            asset.on 'complete', ->
                next()
        , (error) ->
            return @emit 'error', error if error?
            @emit 'complete'

    pushS3: (options) ->
    
    tag: (url) ->
        args = Array.prototype.slice.call arguments, 1
        asset = @assetMapping[url]
        throw new Error "No asset found for url: #{url}" unless asset?
        return asset.tag.apply asset, @options.hostname, args
            
class exports.Asset extends EventEmitter
    mimetype: 'text/plain'
    constructor: (options) ->
        super()
    create: ->
        @emit 'complete'
    tag: ->
    createSpecificUrl: ->
        @md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        @ext = pathutil.extname @url
        @specificUrl = @url.replace new RegExp("#{@ext}"), "-#{@md5}#{@ext}"
        if @hostname?
            @specificUrl = "//#{@hostname}#{@specificUrl}"

exports.LessAsset = require('./assets/less').LessAsset
