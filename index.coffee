
fs = require 'fs'
less = require 'less'
browserify = require('browserify')()
uglify = require 'uglify-js'
crypto = require 'crypto'

assets = []

exports = module.exports = (options) ->
    options = options or new Object
    options.assets = assets
    new AssetsLite options

exports.create (newAssets, next) ->
    create = (asset, next) ->
        assets.push asset
        asset.create next
    async.forEach newAssets, create, next

class AssetsLite
    constructor: (options) ->
        @options.maxAge ?= 60*60*24*7
        @options.context ?= global
        @options.funcName ?= 'assetsLite'
        @options.context[@options.funcName] = (url) =>
            for asset in @assets
                return asset.tag if asset.url is url
            throw new Error "#{url}: Not found in assets."
                    
    handle: (request, response, next) ->
        asset = @assets[request.url]
        return next() unless asset?
        response.header 'Content-Type', asset.mimetype
        response.header 'Cache-Control', "public, max-age=#{@options.maxAge}"
        response.send asset.contents

exports.LessAsset = class LessAsset
    constructor: (@options) ->
        @fileContents = fs.readFileSync @options.path
        
    create: (next) ->
        less.render @fileContents, (error, css) ->
            return next error if error?
            @contents = css
            md5 = crypto.createHash('md5').update(@contents).digest 'hex'
            @specificUrl = @options.url.replace /\.css/, "-#{md5}.css"
            @tag = "<link href=\"#{@specificUrl}\" rel=\"stylesheet\"></link>\n"

exports.BrowserifyAsset = class BrowserifyAsset
    constructor: (@options) ->
        browserify.addEntry @options.path
        if @options.compress?
            @contents = uglify browserify.bundle()
        else
            @contents = browserify.bundle()
        md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        @specificUrl = @options.url.replace /\.js/, "-#{md5}.js"
        @tag = "<script src=\"#{@specificUrl}\"></script>\n"

    create: (next) -> next()
        
