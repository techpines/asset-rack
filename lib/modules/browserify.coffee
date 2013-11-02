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
      agent = browserify watch: false, debug: @debug
      for handler in @extensionHandlers
          agent.register(handler.ext, handler.handler)
      agent.addEntry @filename
      agent.require @require if @require
      
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
          self.contents = contentsArray.join '\n;\n'
          if self.compress is true
            uncompressed = agent.bundle()
            self.contents += uglify.minify(uncompressed, {fromString: true}).code
            self.emit 'created'
          else
            self.emit 'created', contents: self.contents += agent.bundle()
      else
        if @compress is true
              uncompressed = agent.bundle()
              @contents = uglify.minify(uncompressed, {fromString: true}).code
              @emit 'created'
          else
              @emit 'created', contents: agent.bundle()

