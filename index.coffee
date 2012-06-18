
fs = require 'fs'
less = require 'less'
browserify = require('browserify')()
uglify = require 'uglify-js'
crypto = require 'crypto'
async = require 'async'

assets = []

exports = module.exports = (options) ->
    options = options or new Object
    options.assets = assets
    new AssetsLite options

exports.create = (newAssets, next) ->
    create = (asset, next) ->
        assets.push asset
        asset.create next
    async.forEach newAssets, create, next

exports.pushS3 = (key, secret, bucket, next) ->
    async.forEach assets, pushFile, next

pushFile = (asset, next) ->
    client = knox.createClient key: key, secret: secret, bucket: bucket
    client.putFile asset.filename, asset.specificUrl, (error, response) ->
        return next error if error?
        next()

class AssetsLite
    constructor: (@options) ->
        @assets = @options.assets
        @options.hostname ?= ''
        @options.maxAge ?= 60*60*24*7
        @options.context ?= global
        @options.funcName ?= 'assetsTag'
        @options.context[@options.funcName] = (url) =>
            for asset in @assets
                return asset.tag @options.hostname if asset.url is url
            throw new Error "#{url}: Not found in assets."
                    
    handle: (request, response, next) ->
        asset = @getAsset request.url
        return next() unless asset?
        response.header 'Content-Type', asset.mimetype
        response.header 'Cache-Control', "public, max-age=#{@options.maxAge}"
        response.send asset.contents

    getAsset: (specificUrl) ->
        for asset in @assets
            if asset.specificUrl is specificUrl
                return asset

exports.LessAsset = class LessAsset
    mimetype: 'text/css'

    constructor: (@options) ->
        @url = @options.url
        @filename = @options.filename
        @fileContents = fs.readFileSync @filename, 'utf8'
        
    create: (next) ->
        parser = new less.Parser
            filename: @options.filename
            paths: @options.paths
        parser.parse @fileContents, (error, tree) =>
            return next error if error?
            @contents = tree.toCSS compress: @options.compress
            md5 = crypto.createHash('md5').update(@contents).digest 'hex'
            @specificUrl = @url.replace /\.css/, "-#{md5}.css"
            @tag = (hostname) ->
                hostname = "//#{hostname}"
                "<link href=\"#{hostname}#{@specificUrl}\" rel=\"stylesheet\"></link>\n"
            next()

exports.BrowserifyAsset = class BrowserifyAsset
    mimetype: 'application/javascript'

    constructor: (@options) ->
        @filename = @options.filename
        @url = @options.url
        browserify.addEntry @filename
        if @options.compress?
            @contents = uglify browserify.bundle()
        else
            @contents = browserify.bundle()
        md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        @specificUrl = @options.url.replace /\.js/, "-#{md5}.js"
        @tag = (hostname) ->
            hostname = "//#{hostname}"
            "<script src=\"#{hostname}#{@specificUrl}\"></script>\n"

    create: (next) -> next()
        
