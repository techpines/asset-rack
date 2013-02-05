
fs = require 'fs'
pathutil = require 'path'
async = require 'async'
rack = require '../index'
mime = require 'mime'
EventEmitter = require('events').EventEmitter
Asset = require('../.').Asset

class exports.StaticAssetBuilder extends Asset

    create: (options) ->
        @dirname = options.dirname
        @urlPrefix = options.urlPrefix
        @assets = []
        @getAssets @dirname, @urlPrefix, =>
            @emit 'created'
    
    getAssets: (dirname, prefix='', next) ->
        filenames = fs.readdirSync dirname
        async.forEachSeries filenames, (filename, next) =>
            next() if filename.slice(0, 1) is '.'
            path = pathutil.join dirname, filename
            stats = fs.statSync path
            if stats.isDirectory()
                newPrefix = "#{prefix}#{pathutil.basename(path)}/"
                @getAssets path, newPrefix, (newAssets) =>
                    @assets.concat newAssets
                    next()
            else
                basePath = pathutil.dirname @dirname
                url = path.replace basePath, ''
                ext = pathutil.extname path
                mimetype = mime.types[ext.slice(1, ext.length)]
                contents = fs.readFileSync path
                if mimetype?
                    asset = new Asset
                        url: url
                        contents: contents
                        mimetype: mime.types[ext.slice(1, ext.length)]
                        hash: @hash
                        maxAge: @maxAge
                    asset.on 'complete', =>
                        @assets.push asset
                        next()
        , (error) ->
            next()
        
