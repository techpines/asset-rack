Snockets = require 'snockets'
Asset = require('../index').Asset

class exports.SnocketsAsset extends Asset
    mimetype: 'text/javascript'

    create: ->
        @filename = @options.filename
        @compress = @options.compress or false
        snockets = new Snockets()
        @contents = snockets.getConcatenation @filename, { async: false, minify: @compress }
        @emit 'complete'
