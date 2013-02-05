
async = require 'async'
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

describe 'a client rack', ->
    app = null
    it 'should work with no hash', (done) ->
        app = express().http()
        app.use assets = new rack.AssetRack [
            new rack.Asset
                url: '/blank.txt'
                contents: 'test'
            new rack.Asset
                url: '/blank-again.txt'
                contents: 'test-again'
        ]
        assets.on 'compelete', ->
            rack.addClientRack()

    afterEach (done) -> process.nextTick ->
        app.server.close done
        
