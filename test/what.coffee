
async = require 'async'
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

app = null
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
    assets.addClientRack()

app.listen 7076
