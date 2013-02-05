
## Welcome to the Static Web!
<img src="https://s3.amazonaws.com/temp.techpines.com/asset-rack-white.png">

The Static Web is amazing.  The Static Web is blisteringly fast.  The Static Web is ultra efficient.
Get started with asset-rack.  It will change your life. :)  The rest of the docs are in javascript, this one example is in coffeescript for beauty's sake.

```coffeescript
rack = require 'asset-rack'
```

The Static-Web is a modern, high-performance, cutting edge take on the most prolific platform.

## What is an Asset?

> __An asset is a resource on the web that has the following three features:__

1. __Location (URL)__: Where on the web the resource is located.
2. __Contents (HTTP Response Body)__: The body of the response received by a web client.
3. __Meta Data (HTTP Headers)__: Gives information about the resource, like content-type, caching info.

Conceptually, this definition is the bedrock foundation of __asset-rack__.

## Getting Started

Asset-rack is the most advanced static-web framework on any platform.

```js
asset = new rack.Asset({
    url: '/hello.txt'
    contents: 'hello world'
})
```

Need to serve your assets with a blisteringly fast in memory cache using express?  Try this:

```
app.use(asset)
```

What's cool is that this new asset is available both here:

```
/hello-238jf202390fj40.txt
```

What if you have lots of complex assets that depend on one another?  Is there a hero to save us?

Try using a rack!

```js
assets = new rack.AssetRack([
    new rack.Asset({
        url: '/hello.txt',
        contents: 'hello world',
    }),
    new rack.Asset({
        url: '/hello-again.txt',
        contents: 'hello world again',
    })
])
```

# Batteries Included

The above assets are simple to say the least, but we have some professional grade assets included.



Here is our complete list of assets currently available:

#### For Stylesheets
* [Less]() - Compile less assets, ability to use dependencies, gzip, minification.
* [Stylus]() - Compile stylu assets, ability to use dependencies, gzip, minification.

#### For your javascript
* [Browserify]() - Create browserify assets that allow you to use "node-style" requires on the client-side.
* [Snockets]() - Create snockets assets, to get the node-flavor of the "sprockets" from rails.

### Templates
* [Jade]() - High, performance jade templates precompiled for the browser.
* [AngularTemplates]() - AngularJS templates for you AngularJS folks.

#### Other
* [StaticAssets]() - Images(png, jpg, gif), fonts, whatever you got.

# Deploying to the Cloud
A static-web framework needs be deployed.  The deploy mechanism is extremely sophisticated.

## Amazon S3

```js
assets.deploy({
    provider: 'amazon',
    container: 'some-bucket',
    key: '<AWS ACCESS KEY>',
    secret: '<AWS SECRET KEY>',
}, function(error, config) {})
```

## Rackspace Cloud Files
```js
assets.deploy(
    provider: 'rackspace',
    container: 'some-cloud-folder',
    key: '<AWS ACCESS KEY>',
    secret: '<AWS SECRET KEY>',
}, function(error, config) {})
```

## Azure
```js
assets.deploy(
    provider: 'azure',
    container: 'some-cloud-folder',
    key: '<AWS ACCESS KEY>',
    secret: '<AWS SECRET KEY>',
}, function(error, config) {})
```


Or you can create your own assets:

```js
MyCoolAsset = rack.Asset.extends({
    create: function(option) {
        
        // create your asset

        // Once you have the contents of your asset.
        // It is ready to fly.
        this.emit('created', {contents: contents})
    }
})
```

# Assets

Here is our complete list of assets currently available:

#### CSS
* [Less]()
* [Stylus]()

#### Javascript
* [Browserify]()
* [Snockets]()

### Templates
* [Jade]()
* [AngularTemplates]()

#### Other
* [StaticAssets]()

Do you have a cool asset that you would like to share.  Send a pull request, and I'll add it to the list.

# Examples

I have been using this framework for over a year on client projects.  Here are some examples that I can actually show you though!

We open sourced the code for our business site:

[github.com/www.techpines.com]()

And all of the teaser sites for our open source projects:

[github.com/techpines/express-io.org]()
[github.com/techpines/asset-rack.org]()

# License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
