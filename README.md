# AssetsCracker

## Features

1. Dynamic asset creation for js, css, html templates, images, fonts.
2. Support for js/coffescript, browserify (node-style requires).
3. Support for less, jade templates, other static resources (images, fonts)
4. Multi-process, multi-server out of the box.  Share nothing.
5. Filenames hashed for "forever" HTML caching and easy CDN updates.
6. No need to ever compile static files to disk, all-in memory.
7. Ability to push compiled files to Amazon S3 for use with Cloudfront.
8. Can be plugged into express as connect middleware.
9. Easily extensible.

## Install

```bash
npm install git://github.com/techpines/assetcracker.git
```

## Assets

### Less

```coffeescript
lessAsset = new assetCracker.LessAsset
    url: '/style.css'
    filename: "#{__dirname}/path/to/file.less"


```

## License

©2012 Brad Carleton, Tech Pines and available under the [MIT license](http://www.opensource.org/licenses/mit-license.php):

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
