
should = require('chai').should()
rack = require '../.'
express = require 'express'
easyrequest = require 'request'
fs = require 'fs'

describe 'a snockets asset', ->
    app = null
    fixturesDir = "#{__dirname}/fixtures/snockets"

    beforeEach (done) ->
        app = express()
        app.server = app.listen 7076, done

    it 'should work', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/app.js", 'utf8'
        app.use new rack.SnocketsAsset
            filename: "#{fixturesDir}/app.coffee"
            url: '/app.js'
        easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            body.should.equal compiled
            done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/app.min.js", 'utf8'
        app.use new rack.SnocketsAsset
            filename: "#{fixturesDir}/app.coffee"
            url: '/app.js'
            compress: true
        easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            body.should.equal compiled
            done()

    it 'should work with DynamicAssets', (done) ->
        app.use new rack.DynamicAssets
            type: rack.SnocketsAsset
            dirname: "#{fixturesDir}"
            filter: 'coffee'
        easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            body.should.equal fs.readFileSync "#{fixturesDir}/app.js", 'utf8'
            done()

    afterEach (done) -> process.nextTick ->
        app.server.close done
