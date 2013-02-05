
rack = require '../.'

app = require('express.io')().http()
app.use assets = new rack.AssetRack [
    new rack.Asset
        url: '/background.png'
        contents: 'not a real png'
    new rack.LessAsset
        filename: "#{__dirname}/fixtures/less/dependency.less"
        url: '/style.css'
]
app.listen 7076
