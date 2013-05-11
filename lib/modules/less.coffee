less = require 'less'
fs = require 'fs'
pathutil = require 'path'
Asset = require('../.').Asset
urlRegex = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/
urlRegexGlobal = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/g

class exports.LessAsset extends Asset
    mimetype: 'text/css'
    create: (options) ->
        if options.filename
            @filename = pathutil.resolve options.filename
            fileContents = fs.readFileSync @filename, 'utf8'
        else fileContents ?= options.contents
        @paths = options.paths
        @paths ?= []
        @paths.push pathutil.dirname options.filename
        @toWatch = pathutil.dirname @filename
        
        @compress = options.compress
        @compress ?= false
        try
            parser = new less.Parser
                filename: @filename
                paths: @paths
            parser.parse fileContents, (error, tree) =>
                return @emit 'error', ensureLessError(error) if error?
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
            # sometimes less throws an error instead of returning the error
            # via the callback.
            error = ensureLessError error
            @emit 'error', error


# less will throw an object that isn't actually an error
ensureLessError = (error) ->
    if !(error instanceof Error)
        error.filename = "[provided asset content]" if not error.filename
        msg = """Less error: #{error.message}
\tfilename: #{error.filename}
\tline #{error.line} column #{error.column}"""
        line = error.line
        msg += "\n\t..."
        if error.extract?
            for extract in error.extract
              if extract
                msg += "\n\t " + (line++) + ": " + extract
        msg += "\n\t..."
        error = new Error msg
    return error
