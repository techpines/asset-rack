
should = require('chai').should()
rack = require '../.'
express = require 'express'
easyrequest = require 'request'
fs = require 'fs'

describe 'a browserify asset', ->
    app = null
    fixturesDir = "#{__dirname}/fixtures/browserify"

    beforeEach (done) ->
        app = express()
        app.server = app.listen 7076, done

    it 'should work', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/app.js", 'utf8'
        app.use new rack.BrowserifyAsset
            filename: "#{fixturesDir}/app.coffee"
            url: '/app.js'
        easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            body.should.equal compiled
            done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/app.min.js", 'utf8'
        app.use asset = new rack.BrowserifyAsset
            filename: "#{fixturesDir}/app.coffee"
            url: '/app.js'
            compress: true
        easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            done()

    it 'should work with DynamicAssets', (done) ->
        app.use new rack.DynamicAssets
            type: rack.BrowserifyAsset
            dirname: "#{fixturesDir}"
            filter: 'coffee'
        easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            body.should.equal fs.readFileSync "#{fixturesDir}/app.js", 'utf8'
            done()

    # to be implemented
    it 'should work with extension handlers'
    it 'should work with debug option'

    afterEach (done) -> process.nextTick ->
        app.server.close done
