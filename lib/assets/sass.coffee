
fs = require 'fs'
path = require 'path'
nib = require 'nib'
sass = require 'sass'
Asset = require('../.').Asset

class exports.SassAsset extends Asset
    type: 'text/css'
    create: ->
        fs.readFile @filename, 'utf8', (err, data) =>
            return @emit 'error', err if err?
            @contents = sass.render data
            @emit 'complete'
