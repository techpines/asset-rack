
fs = require 'fs'
pathutil = require 'path'
browserify = require 'browserify'
uglify = require 'uglify-js'
crypto = require 'crypto'

module.exports = class BrowserifyAsset
    mimetype: 'application/javascript'

    constructor: (@options) ->
        @filename = @options.filename
        @dirnames = @options.dirnames
        @url = @options.url
        agent = browserify watch: false
        agent.addEntry @filename
        for dirname in @dirnames
            for filename in @getFilenames(dirname)
                agent.addEntry filename
        if @options.compress is true
            @contents = uglify agent.bundle()
        else
            @contents = agent.bundle()
        md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        @specificUrl = @options.url.replace /\.js/, "-#{md5}.js"
        @tag = (hostname) ->
            hostname = "//#{hostname}" if hostname.length isnt 0
            "<script src=\"#{hostname}#{@specificUrl}\"></script>\n"

    getFilenames: (dirname) ->
        filenames = fs.readdirSync dirname
        paths = []
        for filename in filenames
            continue if filename.slice(0, 1) is '.'
            path = pathutil.join dirname, filename
            stats = fs.statSync path
            if stats.isDirectory()
                paths = paths.concat @getFilenames path
            else
                paths.push path
        paths
        

    create: (next) -> next()
        
