
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a static asset builder', ->
    app = null
    
    it 'should work', (done) ->
        compiled = fs.readFileSync './fixtures/snockets/app.js', 'utf8'
        app = express().http()
        app.use new rack.StaticAssetBuilder
            dirname: "#{__dirname}/fixtures/static"
            urlPrefix: '/static'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/static/blank.txt', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/plain'
                body.should.equal compiled
                done()

    afterEach (done) -> process.nextTick ->
        app.server.close done
