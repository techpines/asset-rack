fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
Asset = require('../index').Asset
jade = require('jade')

class exports.AngularTemplatesAsset extends Asset
  mimetype: 'text/javascript'

  create: (options) ->
    options.dirname ?= options.directory # for backwards compatiblity
    @dirname = pathutil.resolve options.dirname
    @toWatch = @dirname
    @compress = options.compress or false
    files = fs.readdirSync @dirname
    templates = []

    for file in files
      if file.match(/\.html$/)
        template = fs.readFileSync(pathutil.join(@dirname, file), 'utf8').replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/'/g, '\\\'')
        templates.push "$templateCache.put('#{file}', '#{template}')"
      else if file.match(/\.jade$/)
        template = fs.readFileSync(pathutil.join(this.dirname, file), 'utf8')
        linker = jade.compile(template);
        if @rack?
          assets = {}
          for asset in @rack.assets
            assets[asset.url] = asset.specificUrl

          @assetsMap = {
            assets:
              assets: assets,
              url: (url)-> @assets[url]
          }
        compiledTemplate = linker(@assetsMap if @assetsMap).replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/'/g, '\\\'')
        templates.push("$templateCache.put('" + file.replace(/\.jade/, '.html') + "', '" + compiledTemplate + "')")

    javascript = "var angularTemplates = function($templateCache) {\n#{templates.join('\n')}}"
    if options.compress is true
      @contents = uglify.minify(javascript, { fromString: true }).code
    else
      @contents = javascript
    @emit 'created'
