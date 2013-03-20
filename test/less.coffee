
should = require('chai').should()
rack = require '../.'
express = require 'express'
easyrequest = require 'request'
fs = require 'fs'

describe 'a less asset', ->
    app = null
    fixturesDir = "#{__dirname}/fixtures/less"

    beforeEach (done) ->
        app = express()
        app.server = app.listen 7076, done

    it 'should work', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/simple.css", 'utf8'
        app.use new rack.LessAsset
            filename: "#{fixturesDir}/simple.less"
            url: '/style.css'
        easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/css'
            body.should.equal compiled
            done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/simple.min.css", 'utf8'
        app.use new rack.LessAsset
            filename: "#{fixturesDir}/simple.less"
            url: '/style.css'
            compress: true
        easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/css'
            body.should.equal compiled
            done()

    it 'should work with paths', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/another.css", 'utf8'
        app.use new rack.LessAsset
            filename: "#{fixturesDir}/another.less"
            url: '/style.css'
            paths: ["#{fixturesDir}/more"]
        easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/css'
            body.should.equal compiled
            done()
        
    it 'should work with the rack', (done) ->
        app.use assets = new rack.AssetRack [
            new rack.Asset
                url: '/background.png'
                contents: 'not a real png'
            new rack.LessAsset
                filename: "#{fixturesDir}/simple.less"
                url: '/simple.css'
            new rack.LessAsset
                filename: "#{fixturesDir}/dependency.less"
                url: '/style.css'
        ]
        easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
            backgroundUrl = assets.url('/background.png')
            body.indexOf(backgroundUrl).should.not.equal -1
            done()

    it 'should work with DynamicAssets', (done) ->
        app.use new rack.DynamicAssets
            type: rack.LessAsset
            dirname: "#{fixturesDir}"
            filter: (file) -> file.ext is '.less' and file.name not in ['another.less', 'syntax-error.less']
        easyrequest 'http://localhost:7076/simple.css', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/css'
            body.should.equal fs.readFileSync "#{fixturesDir}/simple.css", 'utf8'
            done()

    it 'should throw a meaningful error', ->
        should.Throw ->
            app.use assets = new rack.AssetRack [
                asset = new rack.LessAsset
                    filename: "#{fixturesDir}/syntax-error.less"
                    url: '/style.css'
            ]
        should.Throw ->
            app.use assets = new rack.AssetRack [
                asset = new rack.LessAsset
                    contents : """
                    @import "file-that-doesnt-exist.less";
                    body {
                        background-color: blue;
                        div {
                          background-color: pink;
                        }
                    }
                    """
                    url: 'style.css'
            ]

    afterEach (done) -> process.nextTick ->
        app.server.close done
