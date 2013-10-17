fs = require 'fs'
pathutil = require 'path'
browserify = require 'browserify'
uglify = require('uglify-js')
Asset = require('../index').Asset

class exports.BrowserifyAsset extends Asset
    mimetype: 'text/javascript'

    create: (options) ->
        @filename = options.filename
        @toWatch = pathutil.dirname pathutil.resolve @filename
        @require = options.require
        @debug = options.debug or false
        @compress = options.compress
        @external = options.external
        @transform = options.transform
        @compress ?= false
        @extensionHandlers = options.extensionHandlers or []
        agent = browserify watch: false, debug: @debug
        for handler in @extensionHandlers
            agent.register(handler.ext, handler.handler)
        agent.add @filename
        agent.require @require if @require

        agent.external ext for ext in @external if @external
        agent.transform t for t in @transform if @transform

        agent.transform 'coffeeify' if /.coffee$/.test @filename

        agent.bundle (error, src) =>
            return @emit 'error', error if error?
            if @compress is true
                @contents = uglify.minify(src, {fromString: true}).code
                @emit 'created'
            else
                @emit 'created', contents: src
