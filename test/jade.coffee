
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a jade asset', ->
    app = null
    fixturesDir = "#{__dirname}/fixtures/jade"

    it 'should work', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/templates.js", 'utf8'
        app = express().http()
        app.use new rack.JadeAsset
            dirname: fixturesDir
            url: '/templates.js'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/templates.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                body.should.equal compiled
                window = {}
                eval(body)
                testFile = fs.readFileSync "#{fixturesDir}/test.html", 'utf8'
                window.Templates.test().should.equal testFile
                userFile = fs.readFileSync "#{fixturesDir}/user.html", 'utf8'
                window.Templates.user(users: ['fred', 'steve']).should.equal userFile
                done()

    it 'should work in a rack', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/templates-rack.js", 'utf8'
        app = express().http()
        app.use new rack.AssetRack [
            new rack.Asset
                url: '/image.png'
                contents: fs.readFileSync "#{fixturesDir}/image.png", 'utf8'
            new rack.JadeAsset
                dirname: fixturesDir
                url: '/templates-rack.js'
        ]
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/templates-rack.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                body.should.equal compiled
                window = {}
                eval(body)
                testFile = fs.readFileSync "#{fixturesDir}/test.html", 'utf8'
                window.Templates.test().should.equal testFile
                userFile = fs.readFileSync "#{fixturesDir}/user.html", 'utf8'
                window.Templates.user(users: ['fred', 'steve']).should.equal userFile
                dependencyFile = fs.readFileSync "#{fixturesDir}/dependency.html", 'utf8'
                window.Templates.dependency().should.equal dependencyFile
                done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/templates.min.js", 'utf8'
        app = express().http()
        app.use new rack.JadeAsset
            dirname: "#{fixturesDir}"
            url: '/templates.min.js'
            compress: true
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/templates.min.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                body.should.equal compiled
                window = {}
                eval(body)
                testFile = fs.readFileSync "#{fixturesDir}/test.html", 'utf8'
                window.Templates.test().should.equal testFile
                userFile = fs.readFileSync "#{fixturesDir}/user.html", 'utf8'
                window.Templates.user(users: ['fred', 'steve']).should.equal userFile
                done()

    afterEach (done) -> process.nextTick ->
        app.server.close done
