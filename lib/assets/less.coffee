
less = require 'less'
fs = require 'fs'
pathutil = require 'path'
Asset = require('../.').Asset

class exports.LessAsset extends Asset
    mimetype: 'text/css'

    create: ->
        @filename = @options.filename
        @paths = @options.paths
        @compress = @options.compress or false
        try
            fileContents = fs.readFileSync @filename, 'utf8'
            parser = new less.Parser
                filename: @filename
                paths: @paths
            parser.parse fileContents, (error, tree) =>
                return @emit 'error', error if error?
                @contents = tree.toCSS compress: @compress
                @createSpecificUrl()
                @emit 'complete'
        catch error
            @emit 'error', error

    tag: ->
        "<link href=\"#{@specificUrl}\" rel=\"stylesheet\">\n"
