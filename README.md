
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
    url: '/hello.txt',
    contents: 'hello world'
})
```

Need to serve your assets with a blisteringly fast in memory cache using express?

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

Now proxies, browsers, cloud storage, content delivery networks only need to download your asset one single time.

You have versioning, conflict resolution all in one simple mechanism.  You can update your entire entire app instantaneously.  Fast, efficient, static.

### One Rack to rule them all

Assets need to be managed.  Enter the __Rack__.  The rack serializes your assets, allows you to deploy static assets to the cloud, allows you to reference.

Check out a more serious example, where we have a directory structure like this:

```
/static      # all your images, fonts, etc.
/style.less  # a less files with your styles
```

```js
assets = new rack.Rack([
    new rack.StaticAssets({
        urlPrefix: '/static'
        dirname: __dirname + '/static'
    }),
    new rack.LessAsset({
        url: '/style.css'
        filename: __dirname + './style.less'
    }
])
```

Hook it into express:

```js
app.use(assets)
```

### Use in your Templates

And now you can reference your assets in your server side templates.

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

## FAQ

__Why is this better than Connect-Assets?__

That's easy!

* It works with node.js multi-process and cluster.
* More built-in assets.
* Un-opionated, connect-assets dictates your url structure AND directory structure.
* Ability to deploy to the cloud.
* Easy to extend.
* Simpler to use.

With all that said, much thanks to Trevor for writing connect-assets. 

__Why is this better than Grunt?__

Grunt is a great build tool.  Asset Rack is not a build a tool.  It never writes files to disk, there is no "build step".  Everything happens "just in time".

If you have "genuine" build issues, then by all means please use Grunt.  You can even use Grunt with Asset Rack if you want.

However, if you are only using Grunt to manage your static assets, then you should consider upgrading to a badass static web framework like Asset Rack.

__Why is this better than Wintersmith/Jekyll?__

Asset Rack is a static web framework, and at it's core there are only two core abstractions, the `Asset` and `Rack` classes.  Wintersmith and Jekyll are high level frameworks that solve more specific problems.

Wintersmith could consume Asset Rack as a dependency.  If something more high-level fits your specific use case, then by all means that is probably a good fit.  If you need the flexibilty and power of the entire Static Web at your fingertips.

# License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
