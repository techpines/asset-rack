
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
        @compress = options.compress
        @compress ?= false
        @contents = ''
        if @compress
        else
            @assets = []
        async.eachSeries @code, (path, next) =>
            try
                if path instanceof Asset
                    asset = path
                    return asset.on 'complete', =>
                        if @compress
                            @contents += asset.contents
                        else
                            @addAsset asset
                        next()
                    
                fileContent = fs.readFileSync pathutil.join(@dirname, path), 'utf8'
                assetUrl = '/' + path.replace('.coffee', '.js')
                               .replace(/\\/g, '\/')
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
                if @compress
                    @contents += jsContent + '\n'
                else
                    @addAsset new Asset {
                        url: assetUrl
                        contents: jsContent
                    }
                next()
            catch error
                @emit 'error', error
        , =>
            @emit 'created'
    
    tag: ->
        if @assets?
            tag = ''
            for asset in @assets
                tag += "\n<script type=\"text/javascript\" "
                tag += "src=\"#{asset.specificUrl}\"></script>"
            return tag
        if @contents? and @contents isnt ''
            tag = "\n<script type=\"#{@mimetype}\" "
            return tag += "src=\"#{@specificUrl}\"></script>"
                
    setupCoffeescript: ->
        @coffeescript ?= @options.coffeescript or require 'coffee-script'

    setupTypescript: ->
        @typescript ?= @options.typescript or require 'node-typescript'
        
