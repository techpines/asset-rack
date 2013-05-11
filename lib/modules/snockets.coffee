pathutil = require('path')
Snockets = require 'snockets'
Asset = require('../index').Asset

class exports.SnocketsAsset extends Asset
    mimetype: 'text/javascript'

    create: (options) ->
        try
            @filename = pathutil.resolve options.filename
            @toWatch = pathutil.dirname @filename
            @compress = options.compress or false
            @debug = options.debug or false
            snockets = new Snockets()
            if @debug
                files = snockets.getCompiledChain @filename, { async: false }
                scripts = []
                for file in files
                    script = file.js
                        .replace(/\\/g, '\\\\')
                        .replace(/\n/g, '\\n')
                        .replace(/\r/g, '')
                        .replace(/'/g, '\\\'')
                    filename = pathutil.relative(pathutil.dirname(@filename), file.filename)
                        .replace(/\\/g, '\/')
                    scripts.push "// #{filename}\neval('#{script}\\n//@ sourceURL=#{filename}')\n"
                @contents = scripts.join('\n')
            else
                @contents = snockets.getConcatenation @filename, { async: false, minify: @compress }
        catch e
            @emit('error', e)
        @emit 'created'
