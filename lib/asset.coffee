
async = require 'async'
crypto = require 'crypto'
pathutil = require 'path'
zlib = require 'zlib'
mime = require 'mime'

# IE8 Compatibility 
mime.types.js = 'text/javascript'
mime.extensions['text/javascript'] = 'js'

{extend} = require './util'
{EventEmitter} = require 'events'

class exports.Asset extends EventEmitter
    defaultMaxAge: 60*60*24*365 # one year
    constructor: (options) ->
        super()
        options ?= {}
        @url = options.url if options.url?
        @contents = options.contents if options.contents?
        @headers = if options.headers then options.headers else {}
        headers = {}
        for key, value of @headers
            headers[key.toLowerCase()] = value
        @headers = headers
        @ext = pathutil.extname @url
        @mimetype = options.mimetype if options.mimetype?
        @mimetype ?= mime.types[@ext.slice(1, @ext.length)]
        @mimetype ?= 'text/plain'
        @gzip = options.gzip
        @hash = options.hash if options.hash?
        @maxAge = options.maxAge if options.maxAge?
        @allowNoHashCache = options.allowNoHashCache if options.allowNoHashCache?
        @on 'newListener', (event, listener) =>
            if event is 'complete' and @completed is true
                listener()
        @on 'created', (data) =>
            if data?.contents?
                @contents = data.contents
            if data?.assets?
                @assets = data.assets
            if @contents?
                @createSpecificUrl()
                @createHeaders()
            @completed = true
            @emit 'complete'
        @on 'error', (error) =>
            throw error if @listeners 'error' is 1
        @on 'start', =>
            @maxAge ?= @rack?.maxAge
            @maxAge ?= @defaultMaxAge unless @hash is false
            @allowNoHashCache ?= @rack?.allowNoHashCache
            @create options
        process.nextTick =>
            @maxAge ?= @defaultMaxAge
            return @create options unless @rack?

    respond: (request, response) ->
        headers = {}
        if request.url is @url and @allowNoHashCache isnt true
            for key, value of @headers
                headers[key] = value
            delete headers['cache-control']
        else
            headers = @headers
        for key, value of headers
            response.header key, value
        if @gzip
            response.send @gzipContents
        else response.send @contents
        
    checkUrl: (url) ->
        url is @specificUrl or (not @hash? and url is @url)

    handle: (request, response, next) ->
        handle = =>
            if @assets?
                for asset in @assets
                    if asset.checkUrl request.url
                        return asset.respond request, response
            if @checkUrl(request.url)
                @respond request, response
            else next()
        if @completed is true
            handle()
        else @on 'complete', ->
            handle()
        
    create: (options) ->
        @emit 'created'

    createHeaders: ->
        @headers['content-type'] ?= "#{@mimetype}"
        if @gzip
            @headers['content-encoding'] ?= 'gzip'
        #@headers['content-length'] = @contents.length
        if @maxAge?
            @headers['cache-control'] ?= "public, max-age=#{@maxAge}"

    tag: ->
        switch @mimetype
            when 'text/javascript'
                tag = "\n<script type=\"#{@mimetype}\" "
                return tag += "src=\"#{@specificUrl}\"></script>"
            when 'text/css'
                return "\n<link rel=\"stylesheet\" href=\"#{@specificUrl}\">"

    createSpecificUrl: ->
        @md5 = crypto.createHash('md5').update(@contents).digest 'hex'
        if @hash is false
            @useDefaultMaxAge = false
            return @specificUrl = @url
        @specificUrl = "#{@url.slice(0, @url.length - @ext.length)}-#{@md5}#{@ext}"
        if @hostname?
            @specificUrl = "//#{@hostname}#{@specificUrl}"
        if @gzip
            zlib.gzip @contents, (error, gzip) =>
                @gzipContents = gzip
        
    isRelevantUrl: (specificUrl) ->
        baseUrl = @url.slice(0, @url.length - @ext.length)
        if specificUrl.indexOf baseUrl isnt -1 and @ext is pathutil.extname specificUrl
            return true
        return false

    @extend: extend
