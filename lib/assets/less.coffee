
less = require 'less'
fs = require 'fs'
pathutil = require 'path'
Asset = require('../.').Asset

class exports.LessAsset extends Asset
    mimetype: 'text/css'

    create: ->
        @filename = @options.filename
        @paths = @options.paths or []
        @paths.push pathutil.dirname @options.filename
        @compress = @options.compress or false
        try
            fileContents = fs.readFileSync @filename, 'utf8'
            parser = new less.Parser
                filename: @filename
                paths: @paths
            parser.parse fileContents, (error, tree) =>
                return @trigger 'error', error if error?
                raw = tree.toCSS compress: @compress
                if @rack?
                    urlRegex = "url\s*\(\s*'([^']+)'\s*\)"
                    results = raw.match /url\s*\(\s*'([^']+)'\s*\)/g

                    for result in results
                        match = /url\s*\(\s*'([^']+)'\s*\)/.exec result
                        url = match[1]
                        specificUrl = @rack.url url
                        if specificUrl?
                            raw = raw.replace result, "url('#{specificUrl}')"
                @contents = raw
                @emit 'complete'
        catch error
            @emit 'error', error

