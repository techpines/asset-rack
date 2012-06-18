# AssetsLite

Dynamic asset handling that is better than [connect-assets](https://github.com/TrevorBurnham/connect-assets).

## Features

1. Supports both javascript and coffeescript.
2. Uses browserify requires, which let's you do requires node-style.
3. You can require jade templates from your javascript/coffeescript code.
4. Md5 sum always attached to files for caching and CDN usage.
5. No writing built files to disk, ever.
6. Support for less.
7. Can be plugged in as connect middleware.
8. Easily extensible.

## Install

```bash
npm install git://github.com/techpines/assets-lite.git
```

## Setup

```javascript
express = require('express');
assetsLite = require('assets-lite');

setup = function(next) {
    assetsLite.create([
        new assetsLite.LessAsset({
            filename: __dirname + '/style/app.less',
            url: '/style.css'
        }),
        new assetsLite.BrowerifyAsset({
            filename: __dirname + '/client/app.js',
            url: '/app.js'
        })
    ], next);
};

setup(function() {
    app = express.createServer();
    app.configure(function() {
        app.use(assetsLite());
    })
    app.listen(8000)
});
```

### Options

## Markup Function

In your server side jade template, include the jade runtime scripts provided and specify a client side template to load:

```
!= assetsTag('/style.css');
!= assetsTag('/app.js');
```

This will result in the following html code:

```html
<link rel="stylesheet" href="/style-91c65beadfc6440e3e9f35dc2b366f98.css"></link>
<script src="/app-39efeec2cb92f3ad7c9ba8b38f3acd77.js"></script>
```

## License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
