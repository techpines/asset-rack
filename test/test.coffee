
ac = require '../lib/index'

testLess = ->
    asset = new ac.LessAsset
        url: '/style.css'
        filename: "#{__dirname}/fixtures/less/test.less"

    asset.on 'complete', ->
        console.log asset

    asset.create()


testAssets = ->
    assets = new ac.AssetPackage
        assets: [
            new ac.LessAsset
                url: '/style.css'
                filename: "#{__dirname}/fixtures/less/test.less"
        ]
    assets.on 'complete', ->
        console.log 'we is done'
        console.log assets
        console.log assets.tag('/style.css')

testAssets()
