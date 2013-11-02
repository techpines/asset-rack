fs = require 'fs'
pathutil = require 'path'
browserify = require 'browserify'
uglify = require('uglify-js')
Q = require('q')
Asset = require('../index').Asset

class exports.BrowserifyAsset extends Asset
    mimetype: 'text/javascript'

    create: (options) ->
      @filename = options.filename
      @toWatch = pathutil.dirname pathutil.resolve @filename
      @require = options.require
      @debug = options.debug or false
      @compress = options.compress
      @prependAsset = options.prepend
      @compress ?= false
      @extensionHandlers = options.extensionHandlers or []
      @agent = browserify watch: false, debug: @debug
      for handler in @extensionHandlers
          @agent.register(handler.ext, handler.handler)
      @agent.addEntry @filename
      @agent.require @require if @require
      delimiter = '\n;\n'
      
      self = @
      if @prependAsset
        promises = []
        unless @prependAsset instanceof Array
          @prependAsset = [@prependAsset]
        for asset in @prependAsset
          deferred = Q.defer()
          promises.push deferred.promise
          asset.on 'complete', ()->
            deferred.resolve @contents
        Q.all(promises).done (contentsArray)->
          @finish(contentsArray.join(delimiter) + delimiter)
      else
        @finish('')

    finish: (prependContents)->
      uncompressed = prependContents + @agent.bundle()
      if @compress is true
        @contents = uglify.minify(uncompressed, {fromString: true}).code
        @emit 'created'
      else
        @emit 'created', contents: uncompressed 
