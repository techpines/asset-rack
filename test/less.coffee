
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a less asset', ->
    app = null

    it 'should work with no hash', (done) ->
        compiled = fs.readFileSync './fixtures/simple.css', 'utf8'
        app = express().http()
        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/simple.less"
            url: '/style.css'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()
                
    it 'should work with hash', (done) ->
        compiled = fs.readFileSync './fixtures/simple.css', 'utf8'
        app = express().http()
        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/simple.less"
            url: '/style.css'
        app.listen 7076, ->
            url = "http://localhost:7076/style-1d9c7d65a076355bf978ce662dc5254b.css"
            easyrequest url, (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync './fixtures/simple.min.css', 'utf8'
        app = express().http()
        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/simple.less"
            url: '/style.css'
            compress: true
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()

    afterEach (done) -> process.nextTick ->
        app.server.close done
