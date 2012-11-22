path = require('path')
Snockets = require 'snockets'
Asset = require('../index').Asset

class exports.SnocketsAsset extends Asset
    mimetype: 'text/javascript'

    create: ->
        @filename = @options.filename
        @compress = @options.compress or false
        @debug = @options.debug or false
        snockets = new Snockets()
        if @debug
            files = snockets.getCompiledChain @filename, { async: false }
            scripts = []
            for file in files
                script = file.js.replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/'/g, '\\\'')
                filename = path.relative(path.dirname(@filename), file.filename)
                scripts.push "// #{filename}\neval('#{script}\\n//@ sourceURL=#{filename}')\n"
            @contents = scripts.join('\n')
        else
            @contents = snockets.getConcatenation @filename, { async: false, minify: @compress }
        @emit 'complete'
