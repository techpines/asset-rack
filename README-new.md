
## Welcome to the Static Web!

The Static Web is amazing.  The Static Web is blisteringly fast.  The Static Web is ultra efficient.
Get started with asset-rack.  It will change your life. :)  The rest of the docs are in javascript, this one example is in coffeescript for beauty's sake.

```coffeescript
rack = require 'asset-rack'
assets = new rack.Rack [
    new rack.StaticAssetBuilder
        baseUrl: '/static'
        dirname: "#{__dirname}/static"
    new rack.LessAsset
        url: '/style.css'
        filename: "#{__dirname}/style/base.less"
    new rack.BrowserifyAsset
        url: '/app.js'
        filename: "#{__dirname}/client/app.coffee"
    new rack.JadeAsset
        url: '/templates.js'
        dirname: "#{__dirname}/templates"
    new rack.JadeEntryPages
        routes: routes
]
```

## What is the Static Web?

The Static-Web is a modern, high-performance, cutting edge take on the most prolific platform.

## What is an Asset?

A lot of the innovations around asset management came from the Ruby on Rails community.  Here is a snippet from their docs.

> The asset pipeline provides a framework to concatenate and minify or compress Javascript and CSS assets.  It also adds the ability to write these assets in other languages such as CoffeeScript, Sass, and ERB.
> 
> -- Ruby Docs (What is the Asset Pipeline?)

Unfortunately, this is an absolutely terrible definition of assets and asset management.  Talk of javscript, coffeescript, sass, and erb is wrong. Those are *specific* assets, just details.  

To understand the problem we are trying to solve, we need a big boy (or girl) definition:

> __An asset is an unchanging resource on the web.  It has the following three features:__

1. __Location (URL)__: Where on the web the resource is located.
2. __Contents (HTTP Response Body)__: The body of the response received by a web client.
3. __Meta Data (HTTP Headers)__: Gives information about the resource, like content-type, caching info.

Now that we understand what an asset is, we can look at what the ideal framework for managing them would look like.

### Hashing the URL

A major innovation in the treatment of assets came by including a hash of the contents in the URL.

```coffeescript
# From this:
/app.js
# To this:
/app-1f8a85c7751d2b480cbc26d1989f5721.js
```

With this innovation, it is now much simpler to meet the first requirement of an asset, that it be unchanging.  If we update the code in app.js, the url changes, because the hash changes.

With the location and the contents fixed, we can tell web clients like browsers and proxies, to cache these resources forever.  This means each device only has to download new assets exactly one time.  This is supremely efficient from a performance and scalability perspective.

### Static Web Hosting

With the advent of truly scalable static web hosting from the likes of Amazon S3, Rackspace Cloud Files, and Github Pages,  you can now achieve seemingly infinite scalability with almost no effort.

The Write-Once-Read-Many (WORM) systems are perfectly designed for web assets.

### The Dreaded "Build" Step

All too often developers introduce a "build" step into the process of creating their apps. A sever should be able to bootstrap it's entire environment by default.  This is absolutely a guiding priniciple in the ideal asset management framework. _NO BUILD STEP_.

### Freedom of URLs and Project Structure

Most developers and myself included do not want to be told how to arrange our files on disk.  I will arrange them as I see fit for development.  I want an efficient hierarchy that fits the needs of my project.  That goes double, for my URLs.  Every other asset management framework makes assumption about your URLs and your project structure.  

Enough is enough!  This tyranny must end.

### Fundamental Principles of Asset Management
1. You should be able to create any type of asset.
2. You should be able to create assets in any way you like.
3. The framework should not introduce a "build" step.
4. The framework should never tell you how to set up your project structure.
5. The framework should never tell you what your URLs look like.
6. The framework should work automatically with multi-process nodejs.


It is time to demand something better.  This is why I created asset-rack 2.0.  Welcome to the future.
