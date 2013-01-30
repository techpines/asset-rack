
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a less asset', ->
    app = null

    it 'should work', (done) ->
        compiled = fs.readFileSync './fixtures/less/simple.css', 'utf8'
        app = express().http()
        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/less/simple.less"
            url: '/style.css'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync './fixtures/less/simple.min.css', 'utf8'
        app = express().http()
        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/less/simple.less"
            url: '/style.css'
            compress: true
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()

    it 'should work with paths', (done) ->
        compiled = fs.readFileSync "#{__dirname}/fixtures/less/another.css", 'utf8'
        app = express().http()
        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/less/another.less"
            url: '/style.css'
            paths: ["#{__dirname}/fixtures/less/more"]
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                #fs.writeFileSync "#{__dirname}/fixtures/less/another.css", body
                done()
        
    afterEach (done) -> process.nextTick ->
        app.server.close done
