
fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
async = require 'async'
jade = require 'jade'
Asset = require('../index').Asset

class exports.TemplateAsset extends Asset
    mimetype: 'text/javascript'

    create: ->
        @dirname = @options.dirname
        @separator = @options.separator or '/'
        @compress = @options.compress or false
        @clientVariable = @options.clientVariable or 'Templates'
        fileObjects = @getFileobjects @options.dirname
        @contents = "window.#{@clientVariable} = {\n"
        for fileObject in fileObjects
            funcDefinition = "#{fileObject.compiled}"
            wrapper = 'function(locals, attrs, escape, rethrow) { \n'
            wrapper += "return (#{fileObject.compiled})(locals, attrs, escape, rethrow);}"
            @contents += "'#{fileObject.funcName}': #{wrapper},"
        @contents += '};'
        @contents = uglify @contents if @compress
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
                funcName = "#{prefix}#{pathutil.basename(path, @extension)}"
                fileContents = fs.readFileSync path, 'utf8'
                compiled = @compile fileContents,
                    client: true,
                    compileDebug: false,
                    filename: path
                paths.push
                    path: path
                    funcName: funcName
                    compiled: compiled
        paths

class exports.JadeAsset extends exports.TemplateAsset
    extension: '.jade'

    compile: (contents, options) ->
        jade.compile contents, options


#class exports.HandlebarsAsset extends exports.TemplateAsset
#    create: ->
#        @extension = @options.extension or '.html'
#        super()
#
#    compile: (contents, options) ->
#        handlebars.compile contents, options


