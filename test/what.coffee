
async = require 'async'
should = require('chai').should()
rack = require '../.'
express = require 'express.io'
easyrequest = require 'request'
fs = require 'fs'

aws = require('/etc/techpines/aws')
assets = new rack.AssetRack [
    new rack.Asset
        url: '/blank.txt'
        contents: 'test'
    new rack.Asset
        url: '/blank-again.txt'
        contents: 'test-again'
]
console.log aws
assets.on 'complete', ->
    console.log 'did we complete'
    assets.deploy
        provider: 'amazon'
        keyId: aws.key
        key: aws.secret
        container: 'temp.techpines.com'
    , (error) ->
        console.log error
        
