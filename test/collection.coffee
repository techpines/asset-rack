should = require('chai').should()
rack = require '../.'

class DelayedAsset extends rack.Asset
    create: (options) ->
        @delay = options.delay
        build = =>
            @emit 'created', contents: "delay#{@delay}"
        setTimeout build, @delay

class CollectionAsset extends rack.Asset
    create: (options) ->
        for i in [1..options.size]
            @addAsset new DelayedAsset
                delay: i * 100
                url: '/delayed' + i
        @emit 'created'

describe 'an asset collection', ->

    it 'should wait for all sub-assets to build', (done) ->
        asset = new CollectionAsset size: 3
        asset.on 'complete', ->
            subassetsBuilt = true
            for subasset in asset.assets
                subassetsBuilt = false unless subasset.completed
            subassetsBuilt.should.be.ok
            done()
