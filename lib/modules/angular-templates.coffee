fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
Asset = require('../index').Asset

class exports.AngularTemplatesAsset extends Asset
    mimetype: 'text/javascript'

    create: (options) ->
        options.dirname ?= options.directory # for backwards compatiblity
        @dirname = pathutil.resolve options.dirname
        @toWatch = @dirname
        @compress = options.compress or false
        files = fs.readdirSync @dirname
        templates = []

        for file in files when file.match(/\.html$/)
            template = fs.readFileSync(pathutil.join(@dirname, file), 'utf8').replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/'/g, '\\\'')
            templates.push "$templateCache.put('#{file}', '#{template}')"

        javascript = "var angularTemplates = function($templateCache) {\n#{templates.join('\n')}}"
        if options.compress is true
            @contents = uglify.minify(javascript, { fromString: true }).code
        else
            @contents = javascript
        @emit 'created'
