less = require 'less'
fs = require 'fs'
pathutil = require 'path'
Asset = require('../.').Asset
urlRegex = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/
urlRegexGlobal = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/g

class exports.LessAsset extends Asset
    @mimetype: 'text/css'

    create: (options) ->
        @filename = pathutil.resolve options.filename
        @paths = options.paths
        @paths ?= []
        @paths.push pathutil.dirname options.filename
        
        @compress = options.compress
        @compress ?= false
        try
            fileContents = fs.readFileSync @filename, 'utf8'
            parser = new less.Parser
                filename: @filename
                paths: @paths
            parser.parse fileContents, (error, tree) =>
                return @emit 'error', error if error?
                raw = tree.toCSS compress: @compress
                if @rack?
                    results = raw.match urlRegexGlobal
                    if results
                        for result in results
                            match = urlRegex.exec result
                            quote = match[1]
                            url = match[2]
                            specificUrl = @rack.url url
                            if specificUrl?
                                raw = raw.replace result, "url(#{quote}#{specificUrl}#{quote})"
                @emit 'created', contents: raw
        catch error
            if !(error instanceof Error)
                less.writeError error
                error = new Error "Less compilation error"
            @emit 'error', error

