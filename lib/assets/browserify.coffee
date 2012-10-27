
fs = require 'fs'
pathutil = require 'path'
browserify = require 'browserify'
uglify = require 'uglify-js'
crypto = require 'crypto'
Asset = require('../index').Asset

class exports.BrowserifyAsset extends Asset
    mimetype: 'text/javascript'

    create: ->
        @filename = @options.filename
        @require = @options.require
        @compress = @options.compress or false
        @extensionHandlers = @options.extensionHandlers or []
        agent = browserify watch: false
        for handler in @extensionHandlers
          agent.register(handler.ext, handler.handler)
        agent.addEntry @filename
        agent.require @require if @require
        if @options.compress is true
            @contents = uglify agent.bundle()
        else
            @contents = agent.bundle()
        @emit 'complete'
