
fs = require 'fs'
pathutil = require 'path'
async = require 'async'
{Asset} = require '../.'
{walk} = require '../util'

class exports.DynamicAssets extends Asset
    create: (options) ->
        @dirname = pathutil.resolve options.dirname
        {@type, @urlPrefix, @options, @filter} = options
        @urlPrefix += '/' unless @urlPrefix.slice(-1) is '/'
        @options ?= {}
        @options.hash = @hash
        @options.maxAge = @maxAge

        @assets = []
        walk @dirname,
          ignoreFolders: true
          filter: @filter
          , (file, done) =>
            opts =
                url: @urlPrefix + file.relpath
                filename: file.path
            opts[k] = v for own k, v of @options
            asset = new @type opts
            asset.on 'complete', =>
                @assets.push asset
                done()
          , (err) =>
            return @emit 'error', err if err?
            @emit 'created'
