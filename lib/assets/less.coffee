
less = require 'less'
fs = require 'fs'
pathutil = require 'path'
Asset = require('../.').Asset

class exports.LessAsset extends Asset
    mimetype: 'text/css'

    constructor: (@options) ->
        @url = @options.url
        @filename = @options.filename
        @paths = options.paths
        super()

    create: ->
        try
            fileContents = fs.readFileSync @filename, 'utf8'
            parser = new less.Parser
                filename: @filename
                paths: @paths
            parser.parse fileContents, (error, tree) =>
                return @tigger 'error', error if error?
                @contents = tree.toCSS()
                @createSpecificUrl()
                @emit 'complete'
        catch error
            @emit 'error', error

    tag: ->
        "<link href=\"#{@specificUrl}\" rel=\"stylesheet\"></link>\n"
