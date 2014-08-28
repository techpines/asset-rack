fs = require 'fs'
url = require 'url'
pathutil = require 'path'
nib = require 'nib'
stylus = require 'stylus'
Asset = require('../.').Asset
urlRegex = /url\s*\(\s*(['"]?)([^#?'"\)]+)([^'"\)]*)['"]?\s*\)/g

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
                    console.log "#{@filename} stylus compiled"
                    if @rack? and css.indexOf('url') >= 0
                        css = css.replace urlRegex, (match, quote, path, query) =>
                          assetUrl = url.resolve(@url, path)
                          specificUrl = @rack.url(assetUrl)
                          if not specificUrl
                            # asset not found, no replace
                            return match
                          # console.log "updating css url: #{path}#{query}"
                          # console.log "     to point to: #{specificUrl}"
                          return "url(#{quote}#{specificUrl}#{query}#{quote})"

                    @emit 'created', contents: css
