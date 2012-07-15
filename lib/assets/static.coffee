
fs = require 'fs'
pathutil = require 'path'
async = require 'async'
rack = require '../index'
mime = require 'mime'
EventEmitter = require('events').EventEmitter

class exports.StaticAsset extends rack.Asset
    create: ->
        @maxAge = @options.maxAge
        @mimetype = @options.mimetype
        @filename = @options.filename
        @contents = fs.readFileSync @filename
        @ext = pathutil.extname @filename
        @mimetype ?= mime.types[@ext.slice(1, @ext.length)]
        @emit 'complete'

class exports.StaticAssetRack extends rack.AssetRack
    getAssets: (dirname, prefix='') ->
        dirname ?= @dirname
        filenames = fs.readdirSync dirname
        assets = []
        for filename in filenames
            continue if filename.slice(0, 1) is '.'
            path = pathutil.join dirname, filename
            stats = fs.statSync path
            if stats.isDirectory()
                newPrefix = "#{prefix}#{pathutil.basename(path)}/"
                assets = assets.concat @getAssets path, newPrefix
            else
                basePath = pathutil.dirname @dirname
                url = path.replace basePath, ''
                ext = pathutil.extname path
                mimetype = mime.types[ext.slice(1, ext.length)]
                if mimetype?
                    assets.push new exports.StaticAsset
                        url: url
                        filename: path
                        mimetype: mimetype
                        hash: @hash
                        maxAge: @maxAge
        assets
        
