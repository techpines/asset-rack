fs = require 'fs'
pathutil = require 'path'
mime = require 'mime'

{Asset} = require '../.'
{walk} = require '../helpers'

class exports.StaticAssets extends Asset
    create: (options) ->
        @dirname = pathutil.resolve options.dirname
        @urlPrefix = options.urlPrefix
        @urlPrefix += '/' unless @urlPrefix.substr(-1, 1) is '/'
        @assets = []
        {@filter} = options
        @getAssets @dirname, @urlPrefix, =>
            @emit 'created'

    getAssets: (dirname, prefix='', done) ->

        loadAsset = (path, next) =>
            relPath = if dirname == path
                pathutil.basename path
            else
                pathutil.relative dirname, path

            url = pathutil.join prefix, relPath
            ext = pathutil.extname path
            mimetype = mime.types[ext.slice(1, ext.length)]
            if mimetype?
                fs.readFile path, (err, contents) =>
                    asset = new Asset
                        url: url
                        contents: contents
                        mimetype: mime.types[ext.slice(1, ext.length)]
                        hash: @hash
                        maxAge: @maxAge
                    asset.on 'complete', =>
                        next null, asset
            else
                next()

        walk {processFile: loadAsset, filter: @filter}, dirname, (err, assets) =>
            @assets.push assets...
            done err
