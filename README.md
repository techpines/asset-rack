
# Install

```js
npm install asset-rack
```

# Getting Started

Asset-rack is the most advanced asset management framework on any platform.  It embarrasses the Ruby Asset Pipeline.

```js
rack = require('asset-rack')
asset = new rack.Asset({
    url: '/hello.txt'
    contents: 'hello world'
})
```

Now that you have your asset you might want to use it.  That is easy enough, just hook it up to express.

```
app.use(new rack.Asset({
    url: '/hello.txt'
    contents: 'hello world'
})
```

What's cool is that this new asset is available both here:

```
/hello-238jf202390fj40.txt
```

What if we are in production mode and we only want to allow the hash url version:

```js
app.use(new rack.Asset({
    url: '/hello.txt',
    contents: 'hello world',
    hash: true
})
```

What if you have multiple assets?

```js
app.use(new rack.Asset({
    url: '/hello.txt',
    contents: 'hello world',
})
app.use(new rack.Asset({
    url: '/hello-again.txt',
    contents: 'hello world again',
})
```

Or we can use an asset rack, which is an object that holds them all:

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
app.use assets
```

You are probably thinking that this is very simple, and you're right.  How about a more complex example.

```js
assets = new rack.AssetRack([
    new rack.StaticAssetBuilder
        urlPrefix: '/static'
        dirname: "#{__dirname}/static"
    new rack.LessAsset
        url: '/style.css'
        filename: "#{__dirname}/style/base.less"
    new rack.BrowserifyAsset
        url: '/app.js'
        filename: "#{__dirname}/client/app.coffee"
])
```

Well this is cool, now you all of you assets properly hashed and ready to serve.  Or if you are into the static web hosting game.  You might try this:

```
assets.deployS3()
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
