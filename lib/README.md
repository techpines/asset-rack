<img src="https://s3.amazonaws.com/temp.techpines.com/asset-rack-white.png">


# API Reference

## Install

```bash
npm install asset-rack
```

## Asset

This is the base class from which all assets derive.  It can represent both a single asset or a collection of assets.

```js
asset = new Asset({
    url: '/fun.txt',
    contents: 'I am having fun!'
})
```

### Use with Express

Generally, you should wrap your assets in a rack, but for quick and dirty smaller projects you can just use the asset directly.

```
app.use(asset);
```

### Options
* `url`: The url where our resource will be served.
* `contents`: The actual contents to be deliverd by the url.
* `headers`: Any specific headers you want associated with this asset.
* `mimetype`: The content type for the asset.
* `hash`: (defaults to undefined) Serves both hashed and unhashed urls.  If set to `true` then it only serves the hashed version, and if false then it only serves the unhashed version.
* `watch`: (defaults to false) Watches for file changes and recreates assets.
* `gzip`: (defaults to false) Whether to gzip the contents
* `allowNoHashCache`: By default unhashed urls will not be cached.  To allow them to be hashed, set this option to `true`.
* `maxAge`: How long to cache the resource, defaults to 1 year for hashed urls, and no cache for unhashed urls.
* `specificUrl`: The hashed version of the url.
* `assets`: If the asset is actually a collection of assets, then this is where all of it's assets are.

### Methods
* `tag()`: Returns the tag that should be used in HTML. (js and css assets only)
* `respond(req,res)`: Given an express request and response object, this will respond with the contents and headers for the asset.

### Events
* `complete`: Triggered once the asset is fully initialized with contents or assets, and has headers, hashed url etc.
* `created`: Emitted when just the contents or assets have been created, before headers and hashing.
* `error`: Emitted if there is an error with the asset.

### Extending the Asset Class

It is easy to extend the base Asset class.  The procedure for javascript is similar to that of Backbone.js.  You must override the create method for your asset.

```js
MyCoolAsset = rack.Asset.extend({
    create: function(options) {
        this.contents = 'hey there'
        this.emit 'created'
    }
})
```

In coffescript it is a little simpler:

```coffee
class MyCoolAsset extends rack.Asset
    create: (options) ->
        @contents = 'yea!'
        @emit 'created'
```

Whenever you finish creating your contents you emit a __created__ event.

The options object passed to create is the same options object that gets passed to the constructor of new objects.

```coffee
asset = new MyCoolAsset(options)
```

You can also create create a collection of assets by extending the `Asset` class, but instead of setting the contents, you would set an array of assets.

```js
LotsOfAssets = rack.Asset.extend({
    create: function(options) {
        this.assets = []

        // add assets to the collection

        this.emit('created')
    }
})
```

This is pretty self-explanatory, the only caveat is that you need to wait for the assets that you create to `complete` or else you will probably run into some strange behavior.

## Rack

Manage your assets more easily with a rack.

```js
new rack.Rack(assets)
```
#### Options

* `assets`: A collection of assets.

#### Methods
* `tag(url)`: Given a url, returns the tag that should be used in HTML.
* `url(url)`: Get the hashed url from the unhashed url.
* `deploy(options, callback)`: Deploy to the cloud see below.

#### Events

* `complete`: Emitted after all assets have been created.
* `error`: Emitted for any errors.

### With Express

```javascript
app.use(assets);
```
__Important__: You have to call `app.use(assets)` before `app.use(app.router)` or else the `assets` markup functions will not be available in your templates.  The assets middleware needs to come first.

### Deploying

#### Amazon S3

```js
assets.deploy({
    provider: 'amazon',
    container: 'some-bucket',
    accessKey: 'aws-access-key',
    secretKey: 'aws-secret-key',
}, function(error) {})
```

#### Rackspace Cloud Files
```js
assets.deploy(
    provider: 'rackspace',
    container: 'some-container',
    username: 'rackspace-username',
    apiKey: 'rackspace-api-key',
}, function(error) {})
```

#### Azure Storage
```js
assets.deploy(
    provider: 'azure',
    container: 'some-container',
    storageAccount: 'test-storage-account',
    storageAccessKey: 'test-storage-access-key'
}, function(error) {})
```

## Javascript/Coffeescript

### BrowserifyAsset (js/coffeescript)

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

#### Options

* `url`: The url that should retrieve this resource.
* `filename`: A filename or list of filenames to be executed by the browser.
* `require`: A filename or list of filenames to require, should not be necessary
as the `filename` argument should pull in any requires you need.
* `debug` (defaults to false): enables the browserify debug option.
* `compress` (defaults to false): whether to run the javascript through a minifier.
* `extensionHandlers` (defaults to []): an array of custom extensions and associated handler function. eg: `[{ ext: 'handlebars', handler: handlebarsCompilerFunction }]`

### SnocketsAsset (js/coffeescript)

Snockets is a JavaScript/CoffeeScript concatenation tool for Node.js inspired by Sprockets. Used by connect-assets to create a Rails 3.1-style asset pipeline.  For more details, check it out,
[here](https://github.com/TrevorBurnham/snockets).

```javascript
new SnocketsAsset({
    url: '/app.js',
    filename: __dirname + '/client/app.js',
    compress: true
});
```

#### Options

* `url`: The url that should retrieve this resource.
* `filename`: A filename or list of filenames to be executed by the browser.
* `compress` (defaults to false): whether to run the javascript through a minifier.
* `extensionHandlers` (defaults to []): an array of custom extensions and associated handler function. eg: `[{ ext: 'handlebars', handler: handlebarsCompilerFunction }]`
* `debug` (defaults to false): output scripts via eval with trailing //@ sourceURL


## Stylesheets

### LessAsset

The less asset basically compiles up and serves your less files as css.  You
can read more about less [here](https://github.com/cloudhead/less.js).

```javascript
new LessAsset({
    url: '/style.css',
    filename: __dirname + '/style/app.less'
});
```

#### Options

* `url`: The url that should retrieve this resource.
* `filename`: Filename of the less file you want to serve.
* `compress` (defaults to false): Whether to minify the css.
* `paths`: List of paths to search for `@import` directives.

### StylusAsset

The stylus asset serves up your stylus assets.

```javascript
new StylusAsset({
    url: '/style.css',
    filename: __dirname + '/style/fun.styl'
});
```

#### Options

* `url`: The url that should retrieve this resource.
* `filename`: Filename of the less file you want to serve.
* `compress` (defaults to false, or true in production mode): Whether to minify the css.
* `config`: A function that allows custom configuration of the stylus object:
```coffee
new StylusAsset
  url: '/style.css'
  filename: __dirname + '/style/fun.styl'
  config: ->
    @use bootstrap()
    @define 'setting', 90
```

And javascript: 
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


## Templates

### JadeAsset
This is an awesome asset.  Ever wanted the simplicity of jade templates
on the browser with lightning fast performance.  Here you go.

```javascript
new JadeAsset({
    url: '/templates.js',
    dirname: './templates'
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

Then reference your templates on the client like this:

```javascript
$('body').append(Templates['index']());
$('body').append(Templates['user/profile']({username: 'brad', status: 'fun'}));
$('body').append(Templates['user/info']());
```
#### Options

* `url`: The url that should retrieve this resource.
* `dirname`: Directory where template files are located, will grab them recursively.
* `separator` (defaults to '/'): The character that separates directories.
* `compress` (defaults to false): Whether to minify the javascript or not.
* `clientVariable` (defaults to 'Templates'): Client side template
variable.
* `beforeCompile`: A function that takes the jade template as a string and returns a new jade template string before it's compiled into javascript.

### AngularTemplatesAsset

The angular templates asset packages all .html templates ready to be injected into the client side angularjs template cache.
You can read more about angularjs [here](http://angularjs.org/).

```javascript
new AngularTemplatesAsset({
    url: '/js/templates.js',
    dirname: __dirname + '/templates'
});
```

Then see the following example client js code which loads templates into the template cache, where `angularTemplates` is the function provided by AngularTemplatesAsset:

```javascript
//replace this with your module initialization logic
var myApp = angular.module("myApp", []);

//use this line to add the templates to the cache
myApp.run(['$templateCache', angularTemplates]);
```

#### Options

* `url`: The url that should retrieve this resource.
* `dirname`: Directory where the .html templates are stored.
* `compress` (defaults to false): Whether to unglify the js.

## Other

### StaticAssets

```js
new StaticAssets({
    dirname: '/path/to/static'
    urlPrefix: '/static'
})
```

#### Options
* `dirname`: The folder to recursively pull assets from.
* `urlPrefix`: Base url where all assets will be available from.

### DynamicAssets

```js
new DyanmicAssets({
    type: LessAsset
    urlPrefix: '/style'
    dirname: './style'
})
```

Then this would be the equivalent of going through every file in `/style` and doing this:

```js
new LessAsset({
    filename: './style/some-file.less'
    url: '/style/some-file.css'
})
```

#### Options
* `dirname`: The folder to recursively grab files from.
* `type`: The type of Asset to use for each file.
* `urlPrefix`: The url prefix to serve the assets from.
* `options`: Other options to pass to the individual assets.
