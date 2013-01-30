
fs = require 'fs'
path = require 'path'
nib = require 'nib'
stylus = require 'stylus'
Asset = require('../.').Asset

class exports.StylusAsset extends Asset
    mimetype: 'text/css'
    create: (options) ->
        compress = options.compress or false
        paths = options.paths or []

        fs.readFile @filename, 'utf8', (err, data) =>
            return @emit 'error', err if err?
            options =
                filename: @src
                paths: paths.concat [path.dirname @filename]
            stylus(data, options)
                .use(nib())
                .set('compress', compress)
                .set('include css', true)
                .render (err, css) =>
                    return @emit 'error', err if err?
                    @contents = css
                    @emit 'complete'
