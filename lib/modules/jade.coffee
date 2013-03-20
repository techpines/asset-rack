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
        @clientVariable = options.clientVariable or 'Templates'
        @beforeCompile = options.beforeCompile or null
        @fileObjects = @getFileobjects @dirname
        return @createContents() unless @rack
        @clientRack = @rack.createClientRack()
        @clientRack.on 'complete', =>
            @createContents()

    createContents: ->
        @contents = fs.readFileSync require.resolve('jade').replace 'index.js', 'runtime.js'
        @contents += '(function(){ \n' if @clientRack?
        @contents += @clientRack.contents if @clientRack?
        @contents += "window.#{@clientVariable} = {\n"
        for fileObject in @fileObjects
            @contents += "'#{fileObject.funcName}': #{fileObject.compiled},"
        @contents += '};'
        @contents += '})();' if @clientRack?
        @contents = uglify.minify(@contents, {fromString: true}).code if @compress
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
                compiled = jade.compile fileContents,
                    client: true,
                    compileDebug: false,
                    filename: path
                paths.push
                    path: path
                    funcName: funcName
                    compiled: compiled
        paths


