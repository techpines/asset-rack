async = require 'async'
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'
{join} = require 'path'

class CustomAsset extends rack.Asset
    create: (options) ->
        @emit 'created', contents: fs.readFileSync options.filename

describe 'a dynamic asset builder', ->
    app = null
    fixturesDir = join __dirname, 'fixtures'

    it 'should work with any custom asset that takes filename option', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: CustomAsset
            urlPrefix: '/static'
            dirname: join fixturesDir, 'static'
        app.listen 7076, ->
            async.parallel [
                (next) ->
                    easyrequest 'http://localhost:7076/static/blank.txt', (error, response, body) ->
                        response.headers['content-type'].should.equal 'text/plain'
                        body.should.equal fs.readFileSync join(fixturesDir, 'static/blank.txt'), 'utf8'
                        next()
                (next) ->
                    easyrequest 'http://localhost:7076/static/crazy-man.svg', (error, response, body) ->
                        response.headers['content-type'].should.equal 'image/svg+xml'
                        body.should.equal fs.readFileSync join(fixturesDir, 'static/crazy-man.svg'), 'utf8'
                        next()
            ], done

    it 'should work with a rack', (done) ->
        app = express().http()
        app.use new rack.Rack [
            new rack.DynamicAssets
                type: CustomAsset
                urlPrefix: '/static'
                dirname: join fixturesDir, 'static'
        ]
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/static/blank.txt', (error, response, body) ->
                body.should.equal fs.readFileSync join(fixturesDir, 'static/blank.txt'), 'utf8'
                done()

    it 'should work with no urlPrefix option', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: CustomAsset
            dirname: join fixturesDir, 'static'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/blank.txt', (error, response, body) ->
                response.statusCode.should.equal 200
                done()

    it 'should work with options option', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: CustomAsset
            dirname: join fixturesDir, 'static'
            options:
                mimetype: 'text/css'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/blank.txt', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                done()

    it 'should work with a filter', (done) ->
        app = express().http()
        app.use new rack.Rack [
            new rack.DynamicAssets
                type: CustomAsset
                urlPrefix: '/string-filter'
                dirname: join fixturesDir, 'static'
                filter: 'txt'
            new rack.DynamicAssets
                type: CustomAsset
                urlPrefix: '/function-filter'
                dirname: join fixturesDir, 'static'
                filter: (file) -> file.ext is '.svg'
        ]
        app.listen 7076, ->
            async.parallel [
                (next) ->
                    easyrequest 'http://localhost:7076/string-filter/blank.txt', (error, response, body) ->
                        response.statusCode.should.equal 200
                        next()
                (next) ->
                    easyrequest 'http://localhost:7076/string-filter/crazy-man.svg', (error, response, body) ->
                        response.statusCode.should.equal 404
                        next()
                (next) ->
                    easyrequest 'http://localhost:7076/function-filter/blank.txt', (error, response, body) ->
                        response.statusCode.should.equal 404
                        next()
                (next) ->
                    easyrequest 'http://localhost:7076/function-filter/crazy-man.svg', (error, response, body) ->
                        response.statusCode.should.equal 200
                        next()
            ], done

    it 'should work with StylusAsset', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: rack.StylusAsset
            dirname: join fixturesDir, 'stylus'
            filter: 'styl'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/simple.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal fs.readFileSync join(fixturesDir, 'stylus/simple.css'), 'utf8'
                done()

    it 'should work with LessAsset', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: rack.LessAsset
            dirname: join fixturesDir, 'less'
            filter: (file) -> file.ext is '.less' and file.name isnt 'another.less' and file.name isnt 'syntax-error.less'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/simple.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal fs.readFileSync join(fixturesDir, 'less/simple.css'), 'utf8'
                done()

    # TODO: re-enable thi test
    """
    it 'should work with SassAsset', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: rack.SassAsset
            dirname: join fixturesDir, 'sass'
            filter: 'sass'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/simple.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                body.should.equal fs.readFileSync join(fixturesDir, 'sass/simple.css'), 'utf8'
                done()
    """

    it 'should work with SnocketsAsset', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: rack.SnocketsAsset
            dirname: join fixturesDir, 'snockets'
            filter: 'coffee'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                body.should.equal fs.readFileSync join(fixturesDir, 'snockets/app.js'), 'utf8'
                done()

    it 'should work with BrowserifyAsset', (done) ->
        app = express().http()
        app.use new rack.DynamicAssets
            type: rack.BrowserifyAsset
            dirname: join fixturesDir, 'browserify'
            filter: 'coffee'
        app.listen 7076, ->
            easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript'
                #body.should.equal fs.readFileSync join(fixturesDir, 'browserify/app.js'), 'utf8'
                done()

    afterEach (done) -> process.nextTick ->
        app.server.close done
