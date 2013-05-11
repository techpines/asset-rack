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
        @compress ?= false
        @extensionHandlers = options.extensionHandlers or []
        agent = browserify watch: false, debug: @debug
        for handler in @extensionHandlers
            agent.register(handler.ext, handler.handler)
        agent.addEntry @filename
        agent.require @require if @require
        if @compress is true
            uncompressed = agent.bundle()
            @contents = uglify.minify(uncompressed, {fromString: true}).code
            @emit 'created'
        else
            @emit 'created', contents: agent.bundle()

