fs = require 'fs'
pathutil = require 'path'

sassy = require "node-sassy"

{Asset} = require '../.'

urlRegex = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/
urlRegexGlobal = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/g

class exports.SassAsset extends Asset
    mimetype: 'text/css'

    create: (options) ->
        @filename = pathutil.resolve options.filename
        @toWatch = pathutil.dirname @filename
        @paths = options.paths
        @paths ?= []
        @paths.push pathutil.dirname options.filename
        
        @compress = options.compress
        @compress ?= false

        sassOpts = {}
        if options.paths
            sassOpts.includeFrom = options.paths

        if @compress
            sassOpts["--style"] = "compressed"
            
        # Render the sass to css
        sassy.compile @filename, sassOpts, (err, css) =>
            return @emit 'error', err if err?
            
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

            @emit 'created', 
                contents: css
