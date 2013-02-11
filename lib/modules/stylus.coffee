
fs = require 'fs'
pathutil = require 'path'
nib = require 'nib'
stylus = require 'stylus'
Asset = require('../.').Asset

class exports.StylusAsset extends Asset
    create: (options) ->
        @filename = pathutil.resolve options.filename
        @compress = options.compress
        @compress ?= false

        fs.readFile @filename, 'utf8', (error, data) =>
            return @emit 'error', error if error?
            stylus(data)
                .set('filename', @filename)
                .set('compress', @compress)
                .set('include css', true)
                .use(nib())
                .render (error, css) =>
                    return @emit 'error', error if error?
                    if @rack?
                        urlRegex = "url\s*\(\s*'([^']+)'\s*\)"
                        results = css.match /url\s*\(\s*'([^']+)'\s*\)/g
                        if results
                            for result in results
                                match = /url\s*\(\s*'([^']+)'\s*\)/.exec result
                                url = match[1]
                                specificUrl = @rack.url url
                                if specificUrl?
                                    css = css.replace result, "url('#{specificUrl}')"
                    @emit 'created', contents: css
