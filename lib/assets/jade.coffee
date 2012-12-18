
fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
async = require 'async'
jade = require 'jade'
Asset = require('../index').Asset


class exports.JadeAsset extends Asset
    mimetype: 'text/javascript'

    create: ->
        @dirname = @options.dirname
        @separator = @options.separator or '/'
        @compress = @options.compress or false
        @clientVariable = @options.clientVariable or 'Templates'
        fileObjects = @getFileobjects @options.dirname
        @contents = "window.#{@clientVariable} = {"
        for fileObject in fileObjects
            @contents += "'#{fileObject.funcName}': #{fileObject.compiled},"
        @contents += '};'
        @contents = uglify.minify(@contents, { fromString: true }).code if @compress
        @emit 'complete'
        
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
                funcName = "#{prefix}#{pathutil.basename(path, '.jade')}"
                fileContents = fs.readFileSync path, 'utf8'
                compiled = jade.compile fileContents,
                    client: true,
                    compileDebug: false,
                    filename: path
                paths.push
                    path: path
                    funcName: funcName
                    compiled: compiled
        paths

