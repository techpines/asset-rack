
<img src="https://s3.amazonaws.com/temp.techpines.com/asset-rack-white.png">

# The Static Web is here

The Static Web is __blisteringly fast__.  The Static Web is  __ultra efficient__.  The Static Web is __cutting edge__.  And now it has a hero.

```coffeescript
rack = require 'asset-rack'
```

The Static Web is an incredibly modern, high-performance platform for delivering apps and services.  But before you dive-in, you need to start with the basics.  You need to understand the fundamental building block of the static web, the __asset__.


## What is an Asset?

> __An asset is a resource on the web that has the following three features:__

1. __Location (URL)__: Where on the web the resource is located.
2. __Contents (HTTP Response Body)__: The body of the response received by a web client.
3. __Meta Data (HTTP Headers)__: Gives information about the resource, like content-type, caching info.

This simple definition is the theoretical bedrock of this entire framework.

## Getting Started

Asset-Rack is the most advanced Static-Web framework on any platform. Let's look at the most basic example.

```js
asset = new rack.Asset({
    url: '/hello.txt'
    contents: 'hello world'
})
```

Need to serve your assets with a blisteringly fast in memory cache using express?

```
app.use(asset)
```

### Hashing for Speed and Efficiency

What's cool is that this new asset is available both here:

```
/hello
```

And here

```
/hello-5eb63bbbe01eeed093cb22bb8f5acdc3.txt
```

That long string of letters and numbers is the md5 hash of the contents.  If you hit the hash url, then we automatically set the HTTP cache to never expire.  Now proxies, browsers, cloud storage, content delivery networks only need to download your asset one single time.

You have versioning, conflict resolution all in one simple mechanism.  You can update your entire entire app instantaneously.  Fast, efficient, static.

### Enter the Rack

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

#### For Stylesheets
* [Less]() - Compile less assets, ability to use dependencies, gzip, minification.
* [Stylus]() - Compile stylu assets, ability to use dependencies, gzip, minification.

#### For Javascript
* [Browserify]() - Create browserify assets that allow you to use "node-style" requires on the client-side.
* [Snockets]() - Create snockets assets, to get the node-flavor of the "sprockets" from rails.

#### Templates
* [Jade]() - High, performance jade templates precompiled for the browser.
* [AngularTemplates]() - AngularJS templates for you AngularJS folks.

#### Static
* [StaticAssets]() - Images(png, jpg, gif), fonts, whatever you got.

#### Pages
* [Page]() - This is a front page, if your app starts static, then you need on of these guys.

# Deploying to the Cloud
A static-web framework needs be deployed.  The deploy mechanism is extremely sophisticated.

### Amazon S3

```js
assets.deploy({
    provider: 'amazon',
    container: 'some-bucket',
    accessKey: 'aws-access-key',
    secretKey: 'aws-secret-key',
}, function(error, config) {})
```

### Rackspace Cloud Files
```js
assets.deploy(
    provider: 'rackspace',
    container: 'some-container',
    username: 'rackspace-username',
    apiKey: 'rackspace-api-key',
}, function(error, config) {})
```

### Azure Storage
```js
assets.deploy(
    provider: 'azure',
    container: 'some-container',
    storageAccount: 'test-storage-account',
    storageAccessKey: 'test-storage-access-key'
}, function(error, config) {})
```


# Roll your own

Asset-Rack is extremely flexible.  Extend the __Asset__ class and override the __create__ method to roll your own awesomeness, and watch them get automatically ka-pow'ed by your rack.

```js
SuperCoolAsset = rack.Asset.extend({
    create: function(options) {
        this.contents = 'easy, easy'
        this.emit 'created'
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

[Learn more!]()

# Examples

Here are some examples!


* [express-io.org]() - A realtime-web framework with a static page.
* [techpines.com](https://github.com/techpines/techpines.com) - We open sourced techpines.com, so you can see a static-web project in action.

If you have an example you would like to show, then drop my a line. 

# FAQ

[Why is this better than Grunt?]()

[Why is this better than Connect-Assets?]()

[Why is this better than the Rails Asset Pipeline]()

# License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
