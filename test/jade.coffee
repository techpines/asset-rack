
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a jade asset', ->
    app = null

    it 'should work', (done) ->
        compiled = fs.readFileSync './fixtures/jade/templates.js', 'utf8'
        app = express().http()
        app.use new rack.JadeAsset
            dirname: "#{__dirname}/fixtures/jade"
            url: '/templates.js'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/templates.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                body.should.equal compiled
                window = {}
                eval(body)
                testFile = fs.readFileSync "#{__dirname}/fixtures/jade/test.html", 'utf8'
                window.Templates.test().should.equal testFile
                userFile = fs.readFileSync "#{__dirname}/fixtures/jade/user.html", 'utf8'
                window.Templates.user(users: ['fred', 'steve']).should.equal userFile
                done()

    it 'should work in a rack', (done) ->
        compiled = fs.readFileSync './fixtures/jade/templates.js', 'utf8'
        app = express().http()
        app.use new rack.AssetRack [
            new rack.JadeAsset
                dirname: "#{__dirname}/fixtures/jade"
                url: '/templates.js'
        ]
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/templates.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                console.log body
                #body.should.equal compiled
                window = {}
                eval(body)
                testFile = fs.readFileSync "#{__dirname}/fixtures/jade/test.html", 'utf8'
                window.Templates.test().should.equal testFile
                userFile = fs.readFileSync "#{__dirname}/fixtures/jade/user.html", 'utf8'
                window.Templates.user(users: ['fred', 'steve']).should.equal userFile
                done()
        

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync './fixtures/jade/templates.min.js', 'utf8'
        app = express().http()
        app.use new rack.JadeAsset
            dirname: "#{__dirname}/fixtures/jade"
            url: '/templates.js'
            compress: true
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/templates.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                #body.should.equal compiled
                window = {}
                eval(body)
                testFile = fs.readFileSync "#{__dirname}/fixtures/jade/test.html", 'utf8'
                window.Templates.test().should.equal testFile
                userFile = fs.readFileSync "#{__dirname}/fixtures/jade/user.html", 'utf8'
                window.Templates.user(users: ['fred', 'steve']).should.equal userFile
                done()

    afterEach (done) -> process.nextTick ->
        app.server.close done
