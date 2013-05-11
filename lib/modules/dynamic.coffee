
fs = require 'fs'
pathutil = require 'path'
async = require 'async'
mime = require 'mime'
{Asset} = require '../.'
{walk} = require '../util'

class exports.DynamicAssets extends Asset
    create: (options) ->
        @dirname = pathutil.resolve options.dirname
        @toWatch = @dirname
        {@type, @urlPrefix, @options, @filter, @rewriteExt} = options
        @urlPrefix ?= '/'
        @urlPrefix += '/' unless @urlPrefix.slice(-1) is '/'
        @rewriteExt ?= mime.extensions[@type::mimetype] if @type::mimetype?
        @rewriteExt = '.' + @rewriteExt if @rewriteExt? and @rewriteExt[0] isnt '.'
        @options ?= {}
        @options.hash = @hash
        @options.maxAge = @maxAge

        @assets = []
        walk @dirname,
          ignoreFolders: true
          filter: @filter
          , (file, done) =>
            url = pathutil.dirname(file.relpath)
            url = url.split pathutil.sep
            url = [] if url[0] is '.'
            if @rewriteExt?
              url.push file.namenoext + @rewriteExt
            else
              url.push file.name

            opts =
                url: @urlPrefix + url.join '/'
                filename: file.path
            opts[k] = v for own k, v of @options

            @addAsset new @type opts
            done()
        , => @emit 'created'
