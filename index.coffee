
fs = require 'fs'
less = require 'less'
pathutil = require 'path'
browserify = require 'browserify'
uglify = require 'uglify-js'
crypto = require 'crypto'
async = require 'async'
knox = require 'knox'
jade = require 'jade'

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
    client = knox.createClient key: key, secret: secret, bucket: bucket
    pushFile = (asset, next) ->
        headers =
            'Content-Length': asset.contents.length
            'Content-Type': asset.mimetype
        request = client.put asset.specificUrl, headers
        request.on 'response', (response) ->
            response.setEncoding 'utf8'
            returned = ''
            response.on 'data', (data) ->
                returned += data
            response.on 'end', ->
                if response.statusCode is 200
                    next()
                else
                    next new Error returned
        request.end asset.contents
        console.log 'hey ho'
    async.forEach assets, pushFile, next


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

class exports.LessAsset
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
            next()
    tag: (hostname) ->
        hostname = "//#{hostname}" if hostname.length isnt 0
        "<link href=\"#{hostname}#{@specificUrl}\" rel=\"stylesheet\"></link>\n"

class exports.JadeAsset
    mimetype: 'application/javascript'
    constructor: (@options) ->
        @url = @options.url
        fileObjects = @getFileobjects @options.dirname
        @contents = 'window.Templates = {'
        for fileObject in fileObjects
            @contents += "'#{fileObject.funcName}': #{fileObject.compiled},"
        @contents += '};'
        md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        @specificUrl = @url.replace /\.js/, "-#{md5}.js"
        @tag = (hostname) ->
            hostname = "//#{hostname}" if hostname.length isnt 0
            "<script src=\"#{hostname}#{@specificUrl}\"></script>\n"
        
    create: (next) -> next()

    getFileobjects: (dirname, prefix='') ->
        filenames = fs.readdirSync dirname
        paths = []
        for filename in filenames
            continue if filename.slice(0, 1) is '.'
            path = pathutil.join dirname, filename
            stats = fs.statSync path
            if stats.isDirectory()
                newPrefix = "#{prefix}#{pathutil.basename(path)}_"
                paths = paths.concat @getFileobjects path, newPrefix
            else
                funcName = "#{prefix}#{pathutil.basename(path, '.jade')}"
                fileContents = fs.readFileSync path, 'utf8'
                compiled = jade.compile fileContents,
                    client: true,
                    compileDebug: false,
                    filename: path
                paths.push
                    path: path
                    funcName: funcName
                    compiled: compiled
        paths

class exports.BrowserifyAsset
    mimetype: 'application/javascript'

    constructor: (@options) ->
        @filename = @options.filename
        @dirnames = @options.dirnames
        @url = @options.url
        agent = browserify watch: false
        agent.addEntry @filename
        for dirname in @dirnames
            for filename in @getFilenames(dirname)
                agent.addEntry filename
        if @options.compress?
            @contents = uglify agent.bundle()
        else
            @contents = agent.bundle()
        md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        @specificUrl = @options.url.replace /\.js/, "-#{md5}.js"
        @tag = (hostname) ->
            hostname = "//#{hostname}" if hostname.length isnt 0
            "<script src=\"#{hostname}#{@specificUrl}\"></script>\n"

    getFilenames: (dirname) ->
        filenames = fs.readdirSync dirname
        paths = []
        for filename in filenames
            continue if filename.slice(0, 1) is '.'
            path = pathutil.join dirname, filename
            stats = fs.statSync path
            if stats.isDirectory()
                paths = paths.concat @getFilenames path
            else
                paths.push path
        paths
        

    create: (next) -> next()
        
