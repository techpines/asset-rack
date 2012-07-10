
{LessAsset, AssetPackage} = require '../lib/index'

testLess = ->
    asset = new LessAsset
        url: '/style.css'
        filename: "#{__dirname}/fixtures/less/test.less"

    asset.on 'complete', ->
        console.log asset

    asset.create()


testAssets = ->
    assets = new AssetPackage
        assets: [
            new LessAsset
                url: '/style.css'
                filename: "#{__dirname}/fixtures/less/test.less"
        ]
    assets.on 'complete', ->
        console.log 'we is done'
        console.log assets
        console.log assets.tag('/style.css')

testAssets()
