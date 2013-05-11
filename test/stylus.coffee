
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a stylus asset', ->
    app = null
    fixturesDir = "#{__dirname}/fixtures/stylus"

    it 'should work', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/simple.css", 'utf8'
        app = express().http()
        app.use new rack.StylusAsset
            filename: "#{fixturesDir}/simple.styl"
            url: '/style.css'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/simple.min.css", 'utf8'
        app = express().http()
        app.use new rack.StylusAsset
            filename: "#{fixturesDir}/simple.styl"
            url: '/style.css'
            compress: true
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()

    it 'should work with a rack', (done) ->
        app = express().http()
        app.use new rack.Rack [
            new rack.Asset
                url: '/background.png'
                contents: 'not a real png'
            new rack.StylusAsset
                filename: "#{__dirname}/fixtures/stylus/simple.styl"
                url: '/simple.css'
            new rack.StylusAsset
                filename: "#{__dirname}/fixtures/stylus/dependency.styl"
                url: '/dependency.css'
                compress: true
        ]
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/dependency.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                # TODO: Test more thoroughly.
                done()
        
    afterEach (done) -> process.nextTick ->
        app.server.close done
