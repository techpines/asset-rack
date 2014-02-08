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
        @debowerify = options.debowerify
        @debowerify ?= false
        @extensionHandlers = options.extensionHandlers or []
        agent = browserify watch: false, debug: @debug
        for handler in @extensionHandlers
            agent.register(handler.ext, handler.handler)
        agent.add @filename
        agent.require @require if @require
        agent.transform(require('debowerify')) if @debowerify

        if @compress is true
            agent.bundle (err, uncompressed) =>
                @emit 'created', contents: uglify.minify(uncompressed, {fromString: true}).code
        else
            agent.bundle((err, js) => @emit 'created', contents: js)

