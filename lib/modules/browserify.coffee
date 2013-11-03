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
      @toWatch = options.toWatch or pathutil.dirname pathutil.resolve options.filename
      @require = options.require
      @debug = options.debug or false
      @compress = options.compress
      @external = options.external
      @transform = options.transform
      @prependAsset = options.prepend
      @compress ?= false
      @extensionHandlers = options.extensionHandlers or []
      @agent = browserify watch: false, debug: @debug
      for handler in @extensionHandlers
          @agent.register(handler.ext, handler.handler)
      @agent.add @filename if @filename

      if @require
        for r in @require
          if r.file
            @agent.require r.file, r.options
          else
            @agent.require r

      @agent.external ext for ext in @external if @external
      @agent.transform t for t in @transform if @transform

      @agent.transform 'coffeeify' if /.coffee$/.test @filename

      delimiter = '\n;\n'

      if @prependAsset
        promises = []
        unless @prependAsset instanceof Array
          @prependAsset = [@prependAsset]
        @prependAsset.forEach (asset)=>
          deferred = Q.defer()
          promises.push deferred.promise
          asset.on 'complete', ()->
            deferred.resolve asset.contents
        Q.all(promises).done (contentsArray)=>
          @finish(contentsArray.join(delimiter) + delimiter)
      else
        @finish('')

    finish: (prependContents)->
      @agent.bundle 
        debug: @debug, 
        (err, src) =>
          #return @emit 'error', error if error?
          uncompressed = prependContents + src
          if @compress is true
            @contents = uglify.minify(uncompressed, {fromString: true}).code
            @emit 'created'
          else
            @emit 'created', contents: uncompressed
