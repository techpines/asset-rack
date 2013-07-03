
# Index.coffee - Entry point puts all the code together

exports.Asset = require('./asset').Asset
exports.Rack = require('./rack').Rack
exports.fromConfigFile = require('./rack').fromConfigFile
exports.AssetRack = require('./rack').Rack # backwards compatibility with 1.x
exports.DynamicAssets = require('./modules/dynamic').DynamicAssets
exports.LessAsset = require('./modules/less').LessAsset
exports.SassAsset = require('./modules/sass').SassAsset
exports.StylusAsset = require('./modules/stylus').StylusAsset
exports.BrowserifyAsset = require('./modules/browserify').BrowserifyAsset
exports.JadeAsset = require('./modules/jade').JadeAsset
exports.JavascriptAsset = require('./modules/javascript').JavascriptAsset
exports.StaticAssets = require('./modules/static').StaticAssets
exports.SnocketsAsset = require('./modules/snockets').SnocketsAsset
exports.AngularTemplatesAsset = require('./modules/angular-templates').AngularTemplatesAsset

util = require './util'
exports.util =
  walk: util.walk
