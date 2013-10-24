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
    @separator = options.separator or '/'
    @compress = options.compress or false
    @root = options.root

    templates = @getFileObjects(@dirname)
    javascript = "var angularTemplates = function($templateCache) {\n#{templates.join('\n')}}"
    if options.compress is true
      @contents = uglify.minify(javascript, { fromString: true }).code
    else
      @contents = javascript
    @emit 'created'



  getFileObjects: (dirname, prefix='') ->
    files = fs.readdirSync dirname
    templates = []
    for file in files
      continue if file.slice(0, 1) is '.'
      path = pathutil.join dirname, file
      stats = fs.statSync path
      if stats.isDirectory()
          newPrefix = "#{prefix}#{pathutil.basename(path)}#{@separator}"
          templates = templates.concat @getFileObjects path, newPrefix
      else
        if file.match(/\.html$/)
          template = fs.readFileSync(path, 'utf8').replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/'/g, '\\\'')
          templates.push "$templateCache.put('#{path}', '#{template}')"
        else if file.match(/\.jade$/)
          template = fs.readFileSync(path, 'utf8')
          linker = jade.compile(template, {filename: path});
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
          templates.push("$templateCache.put('" + pathutil.join(@root, file).replace(/\.jade/, '.html') + "', '" + compiledTemplate + "')")
    templates
