fs = require 'fs'
path = require 'path'
{Asset} = require '../.'

try
  sassy = false
  sass = require 'node-sass'
catch err
  sassy = true
  sass = require 'node-sassy'
  sass.render = (opts) ->
    sassOpts = includeFrom: opts.includePaths, '--style': opts.outputStyle
    sass.compile opts.file, sassOpts, (err, css) ->
      return opts.error err if err?
      opts.success css

urlRegex = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/
urlRegexGlobal = /url\s*\(\s*(['"])((?:(?!\1).)+)\1\s*\)/g

class exports.SassAsset extends Asset
  @sassy: sassy
  mimetype: 'text/css'

  postProcess: (css) ->
    return css unless @rack?
    results = css.match urlRegexGlobal
    return css unless results?
    for result in results
      match = urlRegex.exec result
      quote = match[1]
      url = match[2]
      specificUrl = @rack.url url
      css = css.replace result, "url(#{quote}#{specificUrl}#{quote})" if specificUrl?
    css

  create: (options) ->
    throw new Error 'Invalid options' unless options? and options.filename?
    @filename = path.resolve options.filename
    @toWatch = path.dirname @filename
    sass.render
      file: @filename
      includePaths: options.paths ? [path.dirname options.filename]
      outputStyle: if options.compress then 'compressed' else 'nested'
      error: (err) => @emit 'error', err
      success: (css) => @emit 'created', contents: @postProcess css