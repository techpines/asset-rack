
rack = require '../lib/index'
assert = require 'assert'

assets = new rack.AssetPackage
    assets: [
        new rack.LessAsset
            url: '/style.css'
            filename: "#{__dirname}/fixtures/less/test.less"
    ,
        new rack.JadeAsset
            url: '/templates.js'
            dirname: "#{__dirname}/fixtures/jade"
    ,
        new rack.BrowserifyAsset
            url: '/app.js'
            filename: "#{__dirname}/fixtures/coffeescript/app.coffee"
            compress: true
    ]
assets.on 'complete', ->
    aws = require '/etc/techpines/aws'
    assets.pushS3
        bucket: 'temp.techpines.com'
        key: aws.key
        secret: aws.secret
    
    assets.on 's3-upload-complete', ->
    assets.on 'error', (error) ->
        console.log error
