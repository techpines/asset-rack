<img src="https://s3.amazonaws.com/temp.techpines.com/asset-rack-white.png">

# Asset Rack speeds your website

Asset Rack speeds the delivery of webpages by concatenating, minifying, and compressing Javascript
and CSS, and then uses fingerprinting so that Javascript and CSS bundles, images, and other assets
can be cached forever without displaying out-of-date information.

Inspired by the Rails asset pipeline, Asset Rack enables Express apps to compile assets and then
serve them from either an in-memory cache, or via automatic deployment to multiple cloud hosting platforms.

Asset Rack speeds up webpage delivery by minimizing the need for HTTP roundtrips. Express already
supports Etags to avoid having to resend an asset if the browser has cached it and the asset has
not changed. But, a separate HTTP roundtrip is still required for the browser to send an
`If-None-Match` and get back `304 Not Modified`. Asset Rack improves on this first by concatenating,
minifying, and compressing potentially dozens of Javascript and CSS files into a single bundle of
each type.

But the best way of speeding up an HTTP rountrip is to avoid making one at all. When the second
page of a website uses the same assets as the first page, and those assets have far future cache
expires headers, then there is no need to even make a single round trip for those assets when
they are requested after the first time.

Fingerprinting is the technique of giving each asset a unique name that is derived fron its
content. Then, when even one bit in an asset (such as a CSS bundle) changes, its name changes,
and so a browser will `GET` the updated asset. And, because Asset Rack fingerpringting uses a
cryptographic hash of the contents, the unique name is calculated the same across Express servers on multiple
machines, as long as the asset is identical. Caches everywhere (CDNs, at ISPs, in networking
equipment, or in web browsers) are able to keep a copy of each asset, but since the HTML references
the unqiue name of each asset, only the correct version of that asset will ever be served from a cache.

```coffeescript
rack = require 'asset-rack'
```

## Getting Started

Let's look at a simple example.

```js
asset = new rack.Asset({
    url: '/hello.txt',
    contents: 'hello world'
})
```

Need to serve that asset with a blisteringly fast in memory cache using express?

```
app.use(asset)
```

### Hash for speed and efficiency

What's cool is that this new asset is available both here:

```
/hello.txt
```

And here

```
/hello-5eb63bbbe01eeed093cb22bb8f5acdc3.txt
```

That long string of letters and numbers is the md5 hash of the contents.  If you hit the hash url, then we automatically set the HTTP cache to __never expire__.  

Now proxies, browsers, cloud storage, content delivery networks only need to download your asset one single time.  You have both versioning and conflict resolution all in one simple mechanism. 

### One Rack to rule them All

Assets need to be managed.  Enter the Rack.  A Rack serializes your assets, allowing you to cache them in RAM or to deploy  them to the cloud, and to easily reference their unique names using urls and tags in your templates.

Say you have a directory structure like this:

```
/static      # all your images, fonts, etc.
/style.less  # a less file with your styles
```

You can create a Rack to put all your assets in.

```js
assets = new rack.Rack([
    new rack.StaticAssets({
        urlPrefix: '/static',
        dirname: __dirname + '/static'
    }),
    new rack.LessAsset({
        url: '/style.css',
        filename: __dirname + '/style.less'
    })
])
```

### Use in your Templates

After you hook into express, you can reference your assets in your server side templates.

```js
assets.tag('/style.css')
```

Which gives you the html tag.

```html
<link href="/style-0f2j9fj039fuw0e9f23.css" rel="stylesheet">
```

Or you can grab just the url.

```js
assets.url('/logo.png')
```

Which gives the hashed url.

```
/logo-34t90j0re9g034o4f3o4f3.png
```

# Batteries Included

We have some professional grade assets included.

#### For Javascript
* [Browserify](https://github.com/techpines/asset-rack/tree/master/lib#browserifyasset-jscoffeescript) - Create browserify assets that allow you to use "node-style" requires on the client-side.
* [Snockets](https://github.com/techpines/asset-rack/tree/master/lib#snocketsasset-jscoffeescript) - Create snockets assets, to get the node-flavor of the "sprockets" from rails.

#### For Stylesheets
* [Less](http://github.com/techpines/asset-rack/tree/master/lib#lessasset) - Compile less assets, ability to use dependencies, minification.
* [Stylus](https://github.com/techpines/asset-rack/tree/master/lib#stylusasset) - Compile stylus assets, ability to use dependencies, minification.

#### Templates
* [Jade](https://github.com/techpines/asset-rack/tree/master/lib#jadeasset) - High, performance jade templates precompiled for the browser.
* [AngularTemplates](https://github.com/techpines/asset-rack/tree/master/lib#angulartemplatesasset) - AngularJS templates for you AngularJS folks.

#### Other
* [StaticAssets](https://github.com/techpines/asset-rack/tree/master/lib#staticassets) - Images(png, jpg, gif), fonts, whatever you got.
* [DynamicAssets](https://github.com/techpines/asset-rack/tree/master/lib#dynamicassets) - For compiling file-based assets like Less or Stylus in an entire directory.

## Roll your own

Asset Rack is extremely flexible.  Extend the __Asset__ class and override the __create__ method to roll your own awesomeness, and watch them get automatically ka-pow'ed by your rack.

```js
SuperCoolAsset = rack.Asset.extend({
    create: function(options) {
        this.contents = 'easy, easy',
        this.emit 'created',
    }
})
```
Or, for those with more refined taste:

```coffee
class SuperCoolAsset extends rack.Asset
    create: (options) ->
        @contents = 'even easier with coffee'
        @emit 'created'
```

Checkout the [tutorial.](https://github.com/techpines/asset-rack/tree/master/lib#extending-the-asset-class)


## Deploying to the Cloud
You may want to deploy your assets to a cloud platform! Here are the current providers that are supported.

### Amazon S3

```js
assets.deploy({
    provider: 'amazon',
    container: 'some-bucket',
    accessKey: 'aws-access-key',
    secretKey: 'aws-secret-key',
}, function(error) {})
```

### Rackspace Cloud Files
```js
assets.deploy(
    provider: 'rackspace',
    container: 'some-container',
    username: 'rackspace-username',
    apiKey: 'rackspace-api-key',
}, function(error) {})
```

### Azure Storage
```js
assets.deploy(
    provider: 'azure',
    container: 'some-container',
    storageAccount: 'test-storage-account',
    storageAccessKey: 'test-storage-access-key'
}, function(error) {})
```

### Running in Production Mode

If you provide the options `configFile` in your deploy options then a config file will be written:

```js
assets.deploy(
    configFile: __dirname + '/rack.json',
    provider: 'amazon',
    container: ...
)
```

Then you can create your assets from the file like this:

```js
assets = rack.fromConfigFile({
    configFile: __dirname + '/rack.json',
    hostname: 'cdn.example.com'
});
app.use(assets);
```

And now all of your server side templates will reference your CDN.  Also, if you do happen to hit one of your static urls on the server, then you will be redirected to the CDN.

## FAQ

#### __Why is this better than Connect-Assets?__

That's easy!

* It works with node.js multi-process and cluster.
* More built-in assets.
* Un-opionated, connect-assets dictates your url structure AND directory structure.
* Ability to deploy to the cloud.
* Easy to extend.
* Simpler to use.

With all that said, much thanks to Trevor for writing connect-assets. 

#### __Why is this better than Grunt?__

Grunt is a great build tool.  Asset Rack is not a build a tool.  It never writes files to disk, there is no "build step".  Everything happens "just in time".

If you have "genuine" build issues, then by all means use Grunt.  You can even use Grunt with Asset Rack.

However, if you are only using Grunt to manage your static assets, then you should consider upgrading to Asset Rack.

#### __Why is this better than Wintersmith(Blacksmith)?__

Asset Rack is a static web framework, and at it's core there are only two abstractions, the `Asset` and `Rack` classes.  Wintersmith is a high level framework that solves a more specific problem.

Wintersmith could consume Asset Rack as a dependency, and if something more high-level fits your specific use case, then by all means that is probably a good fit.  If you need more flexibilty and power, then go with Asset Rack.

# Changelog

### 2.2.1

* A few small tweaks.

### 2.2.0

* Watch and asset recreation is now working.  This should be considered experimental for this version.

```js
new StylusAsset({
    watch: true,
    ...
});
```

* Gzip is here finally.

```js
new BrowserifyAsset({
    gzip: true,
    ...
});
```

* Now adding sub assets to an asset is much simpler, just use `addAsset`.

```js
this.addAsset(asset);
this.emit('created');
```

Thanks @moellenbeck, @d1plo1d, @undashes, and @noc7c9 for contributing!

### 2.1.4

* @vicapow Better error handling for `LessAsset`.

### 2.1.3

* @noc7c9 Added generalized `rack.util.walk` function, need to document the function.
* @noc7c9 Added `DynamicAssets` class.
* @noc7c9 is awesome.

### 2.1.2

* Added ability to configure Stylus, thanks to @noc7c9.

```coffee
new StylusAsset
  url: '/style.css'
  filename: __dirname + '/style/fun.styl'
  config: ->
    @use bootstrap()
    @define 'setting', 90
```

And for javascript:

```js
new StylusAsset({
  url: '/style.css',
  filename: __dirname + '/style/fun.styl',
  config: function (stylus) {
    stylus // using "this" here seems a little unnatural
      .use(bootstrap())
      .define('setting', 90);
  }
});
```

# Test

Testing is easy and fun!

```js
cd asset-rack
npm install
npm test
```

# License

©2013 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
