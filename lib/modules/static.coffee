fs = require 'fs'
pathutil = require 'path'
async = require 'async'
mime = require 'mime'
{EventEmitter} = require 'events'

rack = require '../index'
{Asset} = require '../.'
{walk} = require '../helpers'

class exports.StaticAssets extends Asset
    create: (options) ->
        @dirname = pathutil.resolve options.dirname
        @urlPrefix = options.urlPrefix
        @urlPrefix += '/' unless @urlPrefix.substr(-1, 1) is '/'
        @assets = []
        @getAssets @dirname, @urlPrefix, =>
            @emit 'created'

    getAssets: (dirname, prefix='', done) ->

        loadAsset = (path, next) ->
            relPath = pathutil.relative dirname, path
            url = pathutil.join prefix, relPath
            ext = pathutil.extname path
            mimetype = mime.types[ext.slice(1, ext.length)]
            fs.readFile path, (err, contents) =>
                if mimetype?
                    asset = new Asset
                        url: url
                        contents: contents
                        mimetype: mime.types[ext.slice(1, ext.length)]
                        hash: @hash
                        maxAge: @maxAge
                    asset.on 'complete', =>
                        next null, asset

        walk dirname, loadAsset, (err, assets) =>
            @assets.push assets... if assets?.length > 0
            done err
