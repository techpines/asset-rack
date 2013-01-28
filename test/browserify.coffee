
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a browserify asset', ->
    app = null

    it 'should work with no hash', (done) ->
        compiled = fs.readFileSync './fixtures/app.js', 'utf8'
        app = express().http()
        app.use new rack.BrowserifyAsset
            filename: "#{__dirname}/fixtures/app.coffee"
            url: '/app.js'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                body.should.equal compiled
                done()

    it 'should work with hash', (done) ->
        compiled = fs.readFileSync './fixtures/app.js', 'utf8'
        app = express().http()
        app.use asset = new rack.BrowserifyAsset
            filename: "#{__dirname}/fixtures/app.coffee"
            url: '/app.js'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/app-a8e7810ae8fa22f14e2d61162e27c58f.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                body.should.equal compiled
                done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync './fixtures/app.min.js', 'utf8'
        app = express().http()
        app.use asset = new rack.BrowserifyAsset
            filename: "#{__dirname}/fixtures/app.coffee"
            url: '/app.js'
            compress: true
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                body.should.equal compiled
                done()
                    
        
                
    afterEach (done) -> process.nextTick ->
        app.server.close done
