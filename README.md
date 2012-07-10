
![asset-rack!](http://www.techpines.com/static/logo/asset-rack.png)

## Features

1. Dynamic asset creation for js, css, html templates, images, fonts.
2. Support for js/coffescript, browserify (node-style requires).
3. Support for less, jade templates, other static resources (images, fonts)
4. Multi-process, multi-server out of the box.  Share nothing.
5. Filenames hashed for "forever" HTML caching and easy CDN updates.
6. No need to ever compile static files to disk, all-in memory.
7. Ability to push compiled files to Amazon S3 for use with Cloudfront.
8. Can be plugged into express as connect middleware.
9. Easily extensible.

## Install

```bash
npm install git://github.com/techpines/assetcracker.git
```

## Create your Assets
```coffeescript
ac = require('assetcracker')

assets = new ac.AssetPackage
    assets: [
        new ac.LessAsset
            url: '/style.css'
            filename: "#{__dirname}/path/to/file.less"
    ,
        new ac.BrowserifyAsset
            url: '/app.js'
            filename: "#{__dirname}/path/to/app.coffee"
    ,
        new ac.JadeAsset
            url: '/templates.js'
            dirname: "#{__dirname}/templates"
    ]

assets.on 'complete', ->
    console.log 'hey all my assets are compiled!'
```

## Hook into Express
```coffeescript
assets.on 'complete', ->
    app = express.createServer()
    app.configure ->
        app.use assets.middlware()
```

## Markup Functions

In your jade templates you can include the tags by referencing their url.

```
!= assets.tag('/style.css')
!= assets.tag('/app.js')
!= assets.tag('/templates.js')
```

Which results in the following html:

```html
<link href="/style-c18acfe566c58a63a64165f33c4585a7.css" rel="stylesheet"></link>
<script src="/templates-cb4ef3fab1767499219324ce5664d9d3.js"></script>
<script src="/app-62845fa1d0f145e73ee0a5097493c86a.js"></script>
```

Notice the md5 sum that is now on the url.  This means you can HTML cache it forever.  Which is exactly what we do if you have the hash option set.  Also, updating your CDN is a breeze.

## Push Compiled Assets to S3

```coffeescript
assets.on 'complete', ->
    assets.pushS3
        key: '<your aws key>'
        secret: '<your aws secret>'
        bucket: '<your aws bucket>'
    assets.on 's3-upload-complete', ->
        console.log 'our static files are on amazon s3'
```

## Write a JSON config file.

```coffeescript
fs.writeFileSync '/asset/config.json', JSON.parse(assets.config)
```

## Upload the Config for Express

```coffescript
app = express.createServer()
app.configure ->
    assetConfig = require('/asset/config.json')
    assets = new ac.AssetPackage
        config: require('/asset/config.json')
        hostname: 'static.cloudfront.net' # Or whatever you CDN host might be.
```

## New HTML Output

```html
<link href="//static.cloudfront.net/style-c18acfe566c58a63a64165f33c4585a7.css" rel="stylesheet"></link>
<script src="//static.cloudfront.net/templates-cb4ef3fab1767499219324ce5664d9d3.js"></script>
<script src="//static.cloudfront.net/app-62845fa1d0f145e73ee0a5097493c86a.js"></script>
```     


## API Reference

### AssetPackage

### BrowserifyAsset

### JadeAsset

### LessAsset

```coffeescript
lessAsset = new ac.LessAsset
    url: '/style.css'
    filename: "#{__dirname}/path/to/file.less"
```

## License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
