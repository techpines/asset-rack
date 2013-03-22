
should = require('chai').should()
rack = require '../.'
express = require 'express'
easyrequest = require 'request'
fs = require 'fs'

# disabled due to the SassAsset requiring a ruby gem as a dependency
describe.skip 'a sass asset', ->
    app = null
    fixturesDir = "#{__dirname}/fixtures/sass"

    beforeEach (done) ->
        app = express()
        app.server = app.listen 7076, done

    it 'should work with .scss', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/simple.css", 'utf8'
        app.use new rack.SassAsset
            filename: "#{fixturesDir}/simple.scss"
            url: '/style.css'
        easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/css'
            body.should.equal compiled
            done()

    it 'should work with .sass', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/simple.css", 'utf8'
        app.use new rack.SassAsset
            filename: "#{fixturesDir}/simple.sass"
            url: '/style.css'
        easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/css'
            body.should.equal compiled
            done()
    
    it 'should work compressed', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/simple.min.css", 'utf8'
        app.use new rack.SassAsset
            filename: "#{fixturesDir}/simple.scss"
            url: '/style.css'
            compress: true
        easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/css'
            body.should.equal compiled
            done()

    it 'should work with paths', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/another.css", 'utf8'
        app.use new rack.SassAsset
            filename: "#{fixturesDir}/another.scss"
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
            new rack.SassAsset
                filename: "#{fixturesDir}/simple.scss"
                url: '/simple.css'
            new rack.SassAsset
                filename: "#{fixturesDir}/another.scss"
                url: '/style.css'
                paths: ["#{fixturesDir}/more"]
        ]
        easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
            backgroundUrl = assets.url('/background.png')
            body.indexOf(backgroundUrl).should.not.equal -1 
            done()

    it 'should work with DynamicAssets', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: rack.SassAsset
            dirname: "#{fixturesDir}"
            filter: 'sass'
        easyrequest 'http://localhost:7076/simple.css', (error, response, body) ->
            response.headers['content-type'].should.equal 'text/css'
            body.should.equal fs.readFileSync "#{fixturesDir}/simple.css", 'utf8'
            done()
    
    afterEach (done) -> process.nextTick ->
        app.server.close done
