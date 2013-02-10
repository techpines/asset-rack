
less = require 'less'
fs = require 'fs'
pathutil = require 'path'
Asset = require('../.').Asset

class exports.LessAsset extends Asset
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
                    urlRegex = "url\s*\(\s*'([^']+)'\s*\)"
                    results = raw.match /url\s*\(\s*'([^']+)'\s*\)/g
                    if results
                        for result in results
                            match = /url\s*\(\s*'([^']+)'\s*\)/.exec result
                            url = match[1]
                            specificUrl = @rack.url url
                            if specificUrl?
                                raw = raw.replace result, "url('#{specificUrl}')"
                @emit 'created', contents: raw
        catch error
            @emit 'error', error

