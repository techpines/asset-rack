
![asset-rack!](http://www.techpines.com/static/logo/asset-rack.png)

The best asset management framework for node. (period)

## Features

1. Dynamic asset creation for js, css, html templates, images, fonts.
2. Support for js/coffescript, browserify (node-style requires).
3. Support for less.
4. Support for jade templates.
4. Multi-process, multi-server out of the box.  Share nothing.
5. Filenames hashed for "forever" HTML caching and easy CDN updates.
6. No need to ever compile static files to disk, all-in memory.
7. Ability to push compiled files to Amazon S3 for use with Cloudfront.
8. Can be plugged into express as connect middleware.
9. Easily extensible.

## Install

```bash
npm install asset-rack
```

## Tutorial
Here is a simple walk throught that demonstrates some of the
major features of asset rack.

### Create your Assets
First create your assets.  Here we are creating our stylesheets, 
javascript code, and javascript templates from less, coffeescript and jade.
```coffeescript
rack = require('asset-rack')

assets = new rack.AssetPackage
    assets: [
        new rack.LessAsset
            url: '/style.css'
            filename: "#{__dirname}/path/to/file.less"
        new rack.BrowserifyAsset
            url: '/app.js'
            filename: "#{__dirname}/path/to/app.coffee"
        new rack.JadeAsset
            url: '/templates.js'
            dirname: "#{__dirname}/templates"
    ]

assets.on 'complete', ->
    console.log 'hey all my assets were created!'
```

### Hook into Express
Once your assets have been created you can hook them 
into express with ease.
```coffeescript
assets.on 'complete', ->
    app = express.createServer()
    app.configure ->
        app.use assets
    app.listen 8000
```

### Markup Functions

In your jade templates you can include the tags by referencing their url.

```
!= assets.tag('/style.css')
!= assets.tag('/app.js')
!= assets.tag('/templates.js')
```
Which results in the following html:

```html
<link href="/style-{md5-sum}.css" rel="stylesheet"></link>
<script src="/templates-{md5-sum}.js"></script>
<script src="/app-{md5-sum}.js"></script>
```

Notice the md5 sum that is now on the url.  This means you can HTML cache it forever.  Which is exactly what we do if you have the hash option set.  Also, updating your CDN is a breeze.

### Push Compiled Assets to S3
Now that all your assets are done and hooked into express you can just
serve them from your app, but we can do better!  Let's push them to Amazon
AWS so they can be served by S3 or Cloudfront.

```coffeescript
assets.on 'complete', ->
    assets.pushS3
        key: '<your aws key>'
        secret: '<your aws secret>'
        bucket: '<your aws bucket>'
    assets.on 's3-upload-complete', ->
        console.log 'our static files are on amazon s3'
```

## API Reference

### AssetPackage

This is the top level class that holds collections of assets.

```coffeescript
new AssetPackage
    assets: [
        new rack.LessAsset
            url: '/style.css'
            filename: "#{__dirname}/path/to/file.less"
        new rack.BrowserifyAsset
            url: '/app.js'
            filename: "#{__dirname}/path/to/app.coffee"
        new rack.JadeAsset
            url: '/templates.js'
            dirname: "#{__dirname}/templates"
    ]
```

To use with express:

```coffeescript
app.use assets
```

#### Options

Either a list of assets or a config object is required.

* `assets`: An array of assets to use.

#### Methods
* `create`: Asynchronously creates all the packages assets.
* `tag(url)`: Given a url, returns the tag that should be used in HTML.
* `pushS3`: Pushes all asset contents to their respective 
urls in an Amazon S3 bucket.

#### Events

* `complete`: Emitted by `create` after all assets have been created.
* `s3-upload-complete`: Emitted after assets have been loaded to s3.
* `error`: Emitted for any errors.

### BrowserifyAsset

Browserify is an awesome node project that converts node-style requires
to requirejs for the frontend.  For more details, check it out,
[here](https://github.com/substack/node-browserify).

```coffeescript
new BrowserifyAsset
    url: '/app.js'
    filename: "#{__dirname}/client/app.js"
    compress: true
```

#### Options

* `url`: The url that should retrieve this resource.
* `filename`: A filename or list of filenames to be executed by the browser.
* `require`: A filename or list of filenames to require, should not be necessary
as the `filename` argument should pull in any requires you need.
* `compress` (defaults to false): whether to run the javascript through a minifier.
* `hash` (defaults to true): Set to false if you don't want the md5 sum added to your urls.

### JadeAsset
This is an awesome asset.  Ever wanted the simplicity of jade templates
on the browser with lightning fast performance.  Here you go.

```coffeescript
new JadeAsset
    url: '/templates.js'
    dirname: "#{__dirname}/templates"
```

So if your template directory looked like this:

```
index.jade
contact.jade
user/
    profile.jade
    info.jade
```

Then in the browser, you would first need to include the [jade runtime](https://github.com/visionmedia/jade/blob/master/runtime.js) script
then you could reference your templates like so:

```coffeescript
$('body').append Templates.index() 
$('body').append Templates.contact()
$('body').append Templates['user/profile'](username: 'brad', status: 'fun')
$('body').append Templates['user/info'](
```

You can also change the directory `seperator` option for better template names:

```coffeescript
$('body').append Templates.user_profile(username: 'brad', status: 'fun')
$('body').append Templates.user_info()
```

#### Options

* `url`: The url that should retrieve this resource.
* `dirname`: Directory where template files are located, will grab them recursively.
* `separator` (defaults to '/'): I like to change it like the example above.
* `compress` (defaults to false): Whether to minify the javascript or not.
* `clientVariable` (defaults to 'Templates'): Client side template
variable.
* `hash` (defaults to true): Set to false if you don't want the md5 sum added to your urls.



### LessAsset

The less asset basically compiles up and serves your less files as css.  You
can read more about less [here](https://github.com/cloudhead/less.js).

```coffeescript
lessAsset = new ac.LessAsset
    url: '/style.css'
    filename: "#{__dirname}/style/app.less"
```

#### Options

* `url`: The url that should retrieve this resource.
* `hash` (defaults to true): Set to false if you don't want the md5 sum added to your urls.
* `filename`: Filename of the less file you want to serve.
* `compress` (defaults to false): Whether to minify the css.
* `paths`: List of paths to search for `@import` directives.


## License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
