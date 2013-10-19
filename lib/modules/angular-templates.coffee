fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
Asset = require('../index').Asset
jade = require 'jade'

class exports.AngularTemplatesAsset extends Asset
    mimetype: 'text/javascript'

    addTemplates = (templates, dirname, path) ->
        files = fs.readdirSync dirname

        for file in files
            if file.indexOf(".") is -1
              dir = dirname + "/" + file
              subpath = path + file + "/"
              addTemplates(templates, dir, subpath)
              continue

            continue unless file.match(/(\.html|\.jade)$/)

            if file.match(/\.jade$/)
                template = jade.renderFile(pathutil.join(dirname, file)).replace(/'/g, '\\\'')
            else
                template = fs.readFileSync(pathutil.join(dirname, file), 'utf8').replace(/\\/g, '\\\\').replace(/\n|\r\n|\r/g, '\\n').replace(/'/g, '\\\'')

            templates.push "$templateCache.put('" + path + file + "', '" + template + "')"

    create: (options) ->
        options.dirname ?= options.directory # for backwards compatiblity
        @dirname = pathutil.resolve options.dirname
        @toWatch = @dirname
        @compress = options.compress or false
        
        templates = []

        addTemplates(templates, @dirname, "")

        javascript = "var angularTemplates = function($templateCache) {\n#{templates.join('\n')}}"
        if options.compress is true
            @contents = uglify.minify(javascript, { fromString: true }).code
        else
            @contents = javascript
        @emit 'created'