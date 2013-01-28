fs = require 'fs'
path = require 'path'
uglify = require 'uglify-js'
Asset = require('../index').Asset

class exports.AngularTemplatesAsset extends Asset
    mimetype: 'text/javascript'

    create: ->
        @directory = @options.directory
        @compress = @options.compress or false
        files = fs.readdirSync @directory
        templates = []

        for file in files when file.match(/\.html$/)
            template = fs.readFileSync(path.join(@directory, file), 'utf8').replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/'/g, '\\\'')
            templates.push "$templateCache.put('#{file}', '#{template}')"

        javascript = "var angularTemplates = function($templateCache) {\n#{templates.join('\n')}}"
        if @options.compress is true
            @contents = uglify.minify(javascript, { fromString: true }).code
        else
            @contents = javascript
        @emit 'complete'
