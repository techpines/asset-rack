
fs = require 'fs'
pathutil = require 'path'
async = require 'async'
{Asset} = require '../.'

class exports.JavascriptAsset extends Asset
    mimetype: 'text/javascript'
    create: (options) ->
        @options = options
        @code = options.code
        @dirname = options.dirname or '/'
        @contents = ''
        for path in @code
            try
                fileContent = fs.readFileSync pathutil.join(@dirname, path), 'utf8'
                assetUrl = '/' + path.replace('.coffee', '.js')
                                     .replace(/\\/g, '/')
                jsContent = ''
                switch
                    when path.indexOf('.coffee') isnt -1
                        @setupCoffeescript()
                        try
                            jsContent = @coffeescript.compile fileContent
                        catch error
                            error.stack = "Syntax Error: In #{pathutil.join(@dirname, path)} on line #{error.location.first_line}\n" + error.stack
                            throw error
                    else
                        jsContent = fileContent
                @contents += jsContent
            catch error
                @emit 'error', error
        
        @emit 'created'
                
    setupCoffeescript: ->
        @coffeescript ?= @options.coffeescript or require 'coffee-script'

    setupTypescript: ->
        @typescript ?= @options.typescript or require 'node-typescript'
        
