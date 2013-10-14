
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

# Note: Direct file comparisons for tests exhibited
# cross platform testing issues. 

describe 'a jade asset', ->
    app = null
    fixturesDir = "#{__dirname}/fixtures/jade"

    beforeEach (done) ->
        app = express().http()
        app.listen 7076, done

    it 'should work', (done) ->
        app.use new rack.JadeAsset
            dirname: fixturesDir
            url: '/templates.js'
        easyrequest 'http://localhost:7076/templates.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            window = {}
            eval(body)

            # Due to updates to Jade, runtime.js no longer generates an object called 'jade' but instead attempts
            # to export the module via various ways (exports, window, etc.). Thus, for unit tests run in node,
            # we can get the variable from module.exports.
            jade = module.exports;

            testFile = fs.readFileSync "#{fixturesDir}/test.html", 'utf8'
            window.Templates.test().should.equal testFile
            userFile = fs.readFileSync "#{fixturesDir}/user.html", 'utf8'
            window.Templates.user(users: ['fred', 'steve']).should.equal userFile
            done()

    it 'should work in a rack', (done) ->
        app.use new rack.AssetRack [
            new rack.Asset
                url: '/image.png'
                contents: fs.readFileSync "#{fixturesDir}/image.png", 'utf8'
            new rack.JadeAsset
                dirname: fixturesDir
                url: '/templates-rack.js'
        ]
        easyrequest 'http://localhost:7076/templates-rack.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            window = {}
            eval(body)
            jade = module.exports;
            testFile = fs.readFileSync "#{fixturesDir}/test.html", 'utf8'
            window.Templates.test().should.equal testFile
            userFile = fs.readFileSync "#{fixturesDir}/user.html", 'utf8'
            window.Templates.user(users: ['fred', 'steve']).should.equal userFile
            dependencyFile = fs.readFileSync "#{fixturesDir}/dependency.html", 'utf8'
            console.log window.Templates.dependency()
            window.Templates.dependency().should.equal dependencyFile
            done()

    it 'should work compressed', (done) ->
        app.use new rack.Rack [
            new rack.JadeAsset
                dirname: "#{fixturesDir}"
                url: '/templates.js'
            new rack.JadeAsset
                dirname: "#{fixturesDir}"
                url: '/templates.min.js'
                compress: true
        ]

        easyrequest 'http://localhost:7076/templates.min.js', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/javascript'
            window = {}
            eval(body)
            jade = module.exports;
            testFile = fs.readFileSync "#{fixturesDir}/test.html", 'utf8'
            window.Templates.test().should.equal testFile
            userFile = fs.readFileSync "#{fixturesDir}/user.html", 'utf8'
            window.Templates.user(users: ['fred', 'steve']).should.equal userFile
            easyrequest 'http://localhost:7076/templates.js', (error, response, bodyLong) ->
                bodyLong.length.should.be.above(body.length)
                done()

    afterEach (done) ->
        app.server.close done

