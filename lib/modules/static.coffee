
fs = require 'fs'
pathutil = require 'path'
async = require 'async'
rack = require '../index'
mime = require 'mime'
EventEmitter = require('events').EventEmitter
Asset = require('../.').Asset

class exports.StaticAssets extends Asset
    create: (options) ->
        @dirname = pathutil.resolve options.dirname
        @urlPrefix = options.urlPrefix
        @urlPrefix += '/' unless @urlPrefix.substr(-1, 1) is '/'
        @assets = []
        @getAssets @dirname, @urlPrefix, =>
            @emit 'created'
    
    getAssets: (dirname, prefix='', next) ->
        filenames = fs.readdirSync dirname
        async.forEachSeries filenames, (filename, next) =>
            return next() if filename.slice(0, 1) is '.'
            path = pathutil.join dirname, filename
            stats = fs.statSync path
            if stats.isDirectory()
                newPrefix = "#{prefix}#{pathutil.basename(path)}/"
                @getAssets path, newPrefix, (newAssets) =>
                    @assets.concat newAssets
                    next()
            else
                url = prefix + filename
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
        
