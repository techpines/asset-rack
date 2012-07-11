
rack = require '../lib/index'
assert = require 'assert'

describe 'AssetPackage', ->
    describe '#constructor', ->
        assets = new rack.AssetPackage
            assets: [
                new rack.LessAsset
                    url: '/style.css'
                    filename: "#{__dirname}/fixtures/less/test.less"
                    compress: true
            ,
                new rack.JadeAsset
                    url: '/templates.js'
                    dirname: "#{__dirname}/fixtures/jade"
                    compress: true
            ,
                new rack.BrowserifyAsset
                    url: '/app.js'
                    filename: "#{__dirname}/fixtures/coffeescript/app.coffee"
                    compress: true
            ]
        it 'should run', ->
        it 'should complete', (done) ->
            assets.on 'complete', ->
                console.log assets
                console.log 'cheesy dicks'
                aws = require '/etc/techpines/aws'
                assets.pushS3
                    bucket: 'temp.techines.com'
                    key: aws.key
                    secret: aws.secret
                done()
                
