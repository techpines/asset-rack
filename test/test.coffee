
{Assets, BrowserifyAsset} = require 'assetcracker'
{LessAsset, JadeAsset} = require 'assetcracker'

assets = new Assets
    assets: [
        new BrowserifyAsset
            url: '/app.js'
            filename: "#{__dirname}/client/app.coffee"
        new LessAsset
            url: '/styles.css'
            filename: "#{__dirname}/styles/app.css"
        new JadeAsset
            url: '/templates.js'
            dirname: "#{__dirname}/templates"
        new StaticAsset
            url: '/static'
            dirname: "#{__dirname}/static"
    ]
    hostname: 'static.example.com'

assets = new AssetPackage
    config: require '/etc/myapp/assets.json'
    hostname: 'static.example.com'

assets.tag '/templates.js'
assets.tag '/app.js'
assets.tag '/styles.css'

assets.pushS3
    key: 'your key'
    secret: 'your secret'
    bucket: 'your bucket'

assets.middleware()

assets.config

setup = (next) ->
    assets = new AssetPackage
    assets.on 'complete', ->
        next()

setup ->
    app = express.createServer()
    app.use assets.middleware()
    app.listen 8000
