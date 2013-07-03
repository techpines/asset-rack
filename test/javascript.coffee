
should = require('chai').should()
pathutil = require 'path'
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a javascript asset', ->
    app = null

    it 'should work', (done) ->
        app = express().http()
        app.use new rack.JavascriptAsset {
            url: '/app.js'
            dirname: pathutil.join __dirname, 'fixtures/javascript'
            code: [
                'fun.js'
                'gorilla.coffee'
            ]
        }
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/fun.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                easyrequest 'http://localhost:7076/gorilla.js', (error, response, body) ->
                    response.headers['content-type'].should.equal 'text/javascript'
                    done()

    afterEach (done) -> process.nextTick ->
        app.server.close done

