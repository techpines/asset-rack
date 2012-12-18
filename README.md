
![asset-rack!](http://www.techpines.com/static/logo/asset-rack.png)

A node-style asset management framework. Designed for Single Page Apps.

Inspired by Trevor Burnham's [connect-assets](https://github.com/TrevorBurnham/connect-assets), and the Rails [Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html)

* __Orignal Author__: Brad Carleton
* __Company__: Tech Pines
* __Blog Intro__: [Introducing AssetRack](http://www.techpines.com/blog/asset-rack-dynamic-asset-management-nodejs)

## Features

1. Dynamic asset creation for js, css, html templates.
2. Support for js/coffescript, browserify (node-style requires).
3. Support for snockets (Rails/Sprockets-style comments to indicate dependencies).
4. Support for less.
5. Support for jade templates.
6. Support for angularjs templates.
7. Multi-process, multi-server out of the box.  Share nothing.
8. Filenames hashed for "forever" HTML caching and easy CDN updates.
9. No need to ever compile static files to disk, all-in memory.
10. Ability to push compiled files to Amazon S3 for use with Cloudfront.
11. Can be plugged into express as connect middleware.
12. Easily extensible.

## Install

```bash
npm install asset-rack
```

## Concepts

There are two very simple conepts to understand with asset-rack.

### Asset
An asset after it is `complete`, consists of three very important things.
* `url`: A human readable url.
* `contents`: Contents for the asset, like the actual javascript or image or whatever.
* `md5`: An md5 hash of the contents

These three pieces are absolutely critical.  The md5 hash is *super* important! This allows us to append our human readable url with the md5 hash for versioning which allows basically every static asset to be cached forever by proxies, browsers, cdn's.  This makes everything fast, fast, fast.

### AssetRack
An asset rack is a collection of assets.  But it allows us to do things with assets that we always want to do very easily.  Like serve them from a memory cache using express and connect middleware, or push all individual assets to an Amazon S3 bucket, or write them to disk or whatever other group action we might want to perform on our assets.

## Tutorial
Here is a simple walk throught that demonstrates some of the
major features of asset rack.

### Create your Assets
First create your assets.  Here we are creating our stylesheets,
javascript code, and javascript templates from less, coffeescript and jade.
```javascript
var rack = require('asset-rack');

var assets = new rack.AssetRack([
    new rack.LessAsset({
        url: '/style.css',
        filename: __dirname + '/path/to/file.less'
    }),
    new rack.BrowserifyAsset({
        url: '/app.js',
        filename: __dirname + '/path/to/app.coffee'
    }),
    new rack.JadeAsset({
        url: '/templates.js',
        dirname: __dirname + '/templates'
    })
]);

assets.on('complete', function() {
    console.log('hey all my assets were created!');
});
```

### Hook into Express
Once your assets have been created you can hook them
into express with ease.
```javascript
assets.on('complete', function() {
    var app = express.createServer();
    app.configure(function() {
        app.use(assets);  // that's all you need to do
    });
    app.listen(8000);
});
```

All of those assets are now stored in an in-memroy cache, so it is super fast.

### Markup Functions

In your jade templates you can include the tags by referencing their url.  For your convenience the assets object will be added to response locals, so that you can do the following in say a jade template:

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

Very cool, and this will work for multi-process and multi-server.

Notice the md5 sum that is now on the url.  This means you can HTML cache it forever.  Which is exactly what we do if you have the hash option set.  Also, updating your CDN is now a breeze.

### Push Compiled Assets to S3
Now that all your assets are done and hooked into express you can just
serve them from your app, but we can do better!  Let's push them to Amazon
AWS so they can be served by S3 or Cloudfront.


```javascript
assets.on('complete', function() {
    assets.pushS3({
        key: '<your aws key>',
        secret: '<your aws secret>',
        bucket: '<your aws bucket>'
    });
    assets.on('s3-upload-complete', function() {
        console.log('our assets are now on amazon s3!');
    });
});
```

# API Reference

## AssetRack

This is your initial collection of assets.

```javascript
var assets = new AssetRack([
    new rack.LessAsset({
        url: '/style.css',
        filename: __dirname + '/path/to/file.less'
    }),
    new rack.BrowserifyAsset({
        url: '/app.js',
        filename: __dirname + '/path/to/app.coffee'
    }),
    new rack.JadeAsset({
        url: '/templates.js',
        dirname: __dirname + '/templates'
    })
]);
```

To use with express:

```javascript
app.use(assets);
```

### Methods
* `tag(url)`: Given a url, returns the tag that should be used in HTML.
* `pushS3({key:key, secret:secret, bucket:bucket})`: Pushes all asset contents to their respective
urls in an Amazon S3 bucket.

### Events

* `complete`: Emitted after all assets have been created.
* `s3-upload-complete`: Emitted after assets have been loaded to s3.
* `error`: Emitted for any errors.

## BrowserifyAsset (js/coffeescript)

Browserify is an awesome node project that converts node-style requires
to requirejs for the frontend.  For more details, check it out,
[here](https://github.com/substack/node-browserify).

```javascript
new BrowserifyAsset({
    url: '/app.js',
    filename: __dirname + '/client/app.js',
    compress: true
});
```

### Options

* `url`: The url that should retrieve this resource.
* `filename`: A filename or list of filenames to be executed by the browser.
* `require`: A filename or list of filenames to require, should not be necessary
as the `filename` argument should pull in any requires you need.
* `debug` (defaults to false): enables the browserify debug option.
* `compress` (defaults to false): whether to run the javascript through a minifier.
* `extensionHandlers` (defaults to []): an array of custom extensions and associated handler function. eg: `[{ ext: 'handlebars', handler: handlebarsCompilerFunction }]`
* `hash` (defaults to true): Set to false if you don't want the md5 sum added to your urls.

## Snockets (js/coffeescript)

Snockets is a JavaScript/CoffeeScript concatenation tool for Node.js inspired by Sprockets. Used by connect-assets to create a Rails 3.1-style asset pipeline.  For more details, check it out,
[here](https://github.com/TrevorBurnham/snockets).

```javascript
new SnocketsAsset({
    url: '/app.js',
    filename: __dirname + '/client/app.js',
    compress: true
});
```

### Options

* `url`: The url that should retrieve this resource.
* `filename`: A filename or list of filenames to be executed by the browser.
* `compress` (defaults to false): whether to run the javascript through a minifier.
* `extensionHandlers` (defaults to []): an array of custom extensions and associated handler function. eg: `[{ ext: 'handlebars', handler: handlebarsCompilerFunction }]`
* `debug` (defaults to false): output scripts via eval with trailing //@ sourceURL
* `hash` (defaults to true): Set to false if you don't want the md5 sum added to your urls.

## JadeAsset
This is an awesome asset.  Ever wanted the simplicity of jade templates
on the browser with lightning fast performance.  Here you go.

```javascript
new JadeAsset({
    url: '/templates.js',
    dirname: __dirname + '/templates'
});
```

So if your template directory looked like this:

```
index.jade
contact.jade
user/
    profile.jade
    info.jade
```

Then in the browser, you would first need to include the [jade runtime](https://github.com/visionmedia/jade/blob/master/runtime.js) script:

```
script(src="/static/js/jade-runtime.js", type="text/javascript")
```

then you could reference your templates like so:

```javascript
$('body').append(Templates['index']());
$('body').append(Templates['user/profile']({username: 'brad', status: 'fun'}));
$('body').append(Templates['user/info']());
```
### Options

* `url`: The url that should retrieve this resource.
* `dirname`: Directory where template files are located, will grab them recursively.
* `separator` (defaults to '/'): The character that separates directories, i like to change it to an underscore, `_`.  So that you get more javascript friendly template names like `Templates.user_profile` or `Templates.friends_interests_list`.
* `compress` (defaults to false): Whether to minify the javascript or not.
* `clientVariable` (defaults to 'Templates'): Client side template
variable.
* `hash` (defaults to true): Set to false if you don't want the md5 sum added to your urls.

## AngularTemplatesAsset

The angular templates asset packages all .html templates ready to be injected into the client side angularjs template cache.
You can read more about angularjs [here](http://angularjs.org/).

```javascript
new AngularTemplatesAsset({
    url: '/js/templates.js',
    directory: __dirname + '/templates'
});
```

Then see the following example client js code which loads templates into the template cache, where `angularTemplates` is the function provided by AngularTemplatesAsset:

```javascript
//replace this with your module initialization logic
var myApp = angular.module("myApp", []);

//use this line to add the templates to the cache
myApp.run(['$templateCache', angularTemplates]);
```

### Options

* `url`: The url that should retrieve this resource.
* `hash` (defaults to true): Set to false if you don't want the md5 sum added to your urls.
* `directory`: Directory where the .html templates are stored.
* `compress` (defaults to false): Whether to unglify the js.

## LessAsset

The less asset basically compiles up and serves your less files as css.  You
can read more about less [here](https://github.com/cloudhead/less.js).

```javascript
new LessAsset({
    url: '/style.css',
    filename: __dirname + '/style/app.less'
});
```

### Options

* `url`: The url that should retrieve this resource.
* `hash` (defaults to true): Set to false if you don't want the md5 sum added to your urls.
* `filename`: Filename of the less file you want to serve.
* `compress` (defaults to false): Whether to minify the css.
* `paths`: List of paths to search for `@import` directives.


# License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
