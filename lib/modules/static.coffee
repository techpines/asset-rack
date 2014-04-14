
fs = require 'fs'
pathutil = require 'path'
async = require 'async'
mime = require 'mime'
{Asset} = require '../.'
{DynamicAssets} = require './dynamic'

class exports.StaticAsset extends Asset
    create: (options) ->
        @filename = pathutil.resolve options.filename
        @mimetype ?= mime.types[pathutil.extname(@filename).slice 1] || 'text/plain'

        fs.readFile @filename, (error, data) =>
            return @emit 'error', error if error?
            @emit 'created', contents: data

class exports.StaticAssets extends DynamicAssets
    constructor: (options) ->
        options?.type = exports.StaticAsset
        super options
