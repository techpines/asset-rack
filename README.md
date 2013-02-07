
<img src="https://s3.amazonaws.com/temp.techpines.com/asset-rack-white.png">
<br>
Static-web framework for node.js.

```coffeescript
rack = require 'asset-rack'
```
### The Static Web is:

* __blisteringly fast__
* __ultra efficient__
* __cutting edge__


The Static-Web is an amazing, modern, high-performance, platform for delivering apps and services.  But before you dive head first into the deep end, you need to start with the basics.  You need to understand the fundamental building block of the static web, the asset.

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
    username: 'rackspace-usernam',
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


# Create your Own!

This framework is extremely flexible.  Extend the __Asset__ class and override the __create__ method to create your own awesome assets, and watch them get automatically ka-pow'ed by your rack.

```js
var SuperCoolAsset = rack.newAsset({
    create: function(options) {
        this.contents = 'easy, easy' // set your contents
        this.emit 'created' // let us know your done
    }

})
```

[Learn more!]()

# Examples

Here are some examples!


* [express-io.org]() - A realtime-web framework with a static page.
* [techpines.com](https://github.com/techpines/techpines.com) - We open sourced techpines.com, so you can see a static-web project in action.

If you have an example you would like to show, then drop my a line. 

# License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
