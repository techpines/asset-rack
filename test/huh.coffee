
rack = require '../.'
express = require 'express.io'

app = express().http()
asset = new rack.LessAsset
    filename: "#{__dirname}/fixtures/simple.less"
    url: '/style.css'
app.use asset
asset.on 'complete', ->
    console.log asset
console.log asset
app.listen 7076, ->
