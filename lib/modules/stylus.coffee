fs = require 'fs'
pathutil = require 'path'
nib = require 'nib'
stylus = require 'stylus'
Asset = require('../.').Asset
urlRegex = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/
urlRegexGlobal = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/g

class exports.StylusAsset extends Asset
    mimetype: 'text/css'

    create: (options) ->
        @filename = pathutil.resolve options.filename
        @toWatch = pathutil.dirname @filename
        @compress = options.compress
        @compress ?= process.env.NODE_ENV == 'production'
        @config = options.config
        @config ?= ->
          @use nib()

        fs.readFile @filename, 'utf8', (error, data) =>
            return @emit 'error', error if error?
            styl = stylus(data)
                .set('compress', @compress)
                .set('include css', true)

            @config.call styl, styl

            styl
                .set('filename', @filename)
                .render (error, css) =>
                    return @emit 'error', error if error?
                    if @rack?
                        results = css.match urlRegexGlobal
                        if results
                            for result in results
                                match = urlRegex.exec result
                                quote = match[1]
                                url = match[2]
                                specificUrl = @rack.url url
                                if specificUrl?
                                    css = css.replace result, "url(#{quote}#{specificUrl}#{quote})"
                    @emit 'created', contents: css
