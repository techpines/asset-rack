
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a sass asset', ->
    app = null

    it 'should work with .scss', (done) ->
        compiled = fs.readFileSync "#{__dirname}/fixtures/sass/simple.css", 'utf8'
        app = express().http()
        app.use new rack.SassAsset
            filename: "#{__dirname}/fixtures/sass/simple.scss"
            url: '/style.css'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()
    
    it 'should work compressed', (done) ->
        file = "#{__dirname}/fixtures/sass/simple.min.css"
        file = "#{file}.sassy" if rack.SassAsset.sassy
        compiled = fs.readFileSync file, 'utf8'
        app = express().http()
        app.use new rack.SassAsset
            filename: "#{__dirname}/fixtures/sass/simple.scss"
            url: '/style.css'
            compress: true
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()

    it 'should work with paths', (done) ->
        file = "#{__dirname}/fixtures/sass/another.css"
        file = "#{file}.sassy" if rack.SassAsset.sassy
        compiled = fs.readFileSync file, 'utf8'
        app = express().http()
        app.use new rack.SassAsset
            filename: "#{__dirname}/fixtures/sass/another.scss"
            url: '/style.css'
            paths: ["#{__dirname}/fixtures/sass/more"]
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal compiled
                done()
        
    it 'should work with the rack', (done) ->
        app = express().http()
        app.use assets = new rack.AssetRack [
            new rack.Asset
                url: '/background.png'
                contents: 'not a real png'
            new rack.SassAsset
                filename: "#{__dirname}/fixtures/sass/simple.scss"
                url: '/simple.css'
            new rack.SassAsset
                filename: "#{__dirname}/fixtures/sass/another.scss"
                url: '/style.css'
                paths: ["#{__dirname}/fixtures/sass/more"]
        ]
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                backgroundUrl = assets.url('/background.png')
                body.indexOf(backgroundUrl).should.not.equal -1 
                done()
    
    afterEach (done) -> process.nextTick ->
        app.server.close done
