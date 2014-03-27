fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
async = require 'async'
jade = require 'jade'
Asset = require('../index').Asset

class exports.JadeAsset extends Asset
    mimetype: 'text/javascript'

    create: (options) ->
        @dirname = pathutil.resolve options.dirname
        @separator = options.separator or '/'
        @compress = options.compress or false
        @toWatch = @dirname
        @clientVariable = options.clientVariable or 'Templates'
        @beforeCompile = options.beforeCompile or null
        @fileObjects = @getFileobjects @dirname
        if @rack?
            assets = {}
            for asset in @rack.assets
                assets[asset.url] = asset.specificUrl

            @assetsMap = """
                var assets = { 
                    assets: #{JSON.stringify(assets)},
                    url: #{(url) -> @assets[url]}
                };
            """
        @createContents()

    createContents: ->
        @contents = fs.readFileSync require.resolve('jade').replace 'index.js', 'runtime.js'
        @contents += '(function(){ \n' if @assetsMap?
        @contents += @assetsMap if @assetsMap?
        @contents += "window.#{@clientVariable} = {\n"
        @fileContents = ""

        for fileObject in @fileObjects
            if @fileContents.length > 0
                @fileContents += ","

            if @assetsMap?
                @fileContents += """'#{fileObject.funcName}': function(locals) {
                    locals = locals || {};
                    locals['assets'] = assets;
                    return (#{fileObject.compiled})(locals)
                }"""
            else
                @fileContents += "'#{fileObject.funcName}': #{fileObject.compiled}"
            
        @contents += @fileContents
        @contents += '};'
        @contents += '})();' if @assetsMap?
        @contents = uglify.minify(@contents, {fromString: true}).code if @compress
        unless @hasError
            @emit 'created'
        
    getFileobjects: (dirname, prefix='') ->
        filenames = fs.readdirSync dirname
        paths = []
        for filename in filenames
            continue if filename.slice(0, 1) is '.'
            path = pathutil.join dirname, filename
            stats = fs.statSync path
            if stats.isDirectory()
                newPrefix = "#{prefix}#{pathutil.basename(path)}#{@separator}"
                paths = paths.concat @getFileobjects path, newPrefix
            else
                continue if filename.indexOf('.jade') is -1
                funcName = "#{prefix}#{pathutil.basename(path, '.jade')}"
                fileContents = fs.readFileSync path, 'utf8'
                fileContents = @beforeCompile fileContents if @beforeCompile?
                try
                    compiled = jade.compile fileContents,
                        client: true,
                        compileDebug: false,
                        filename: path
                    paths.push
                        path: path
                        funcName: funcName
                        compiled: compiled
                catch error
                    @hasError = true
                    @emit 'error', error
        paths


