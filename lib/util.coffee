
# Util.coffee - A few utility methods

# Pull in dependencies
EventEmitter = require('events').EventEmitter
Buffer = require('buffer').Buffer
_ = require 'underscore'
fs = require 'fs'
pathutil = require 'path'
async = require 'async'

# Fake stream for buffer that pretends like it's a stream
class exports.BufferStream extends EventEmitter
    constructor: (buffer) ->
        @data = new Buffer buffer
        super()

    pipe: (destination) ->
        destination.write @data
        destination.end()
        @emit 'close'
        @emit 'end'
    pause: ->
    resume: ->
    destroy: ->
    readable: true

# Ability to extend a base class
exports.extend = (object) ->
    class Asset extends this
    for key, value of object
        Asset::[key] = value
    Asset

# Generalized walk function
exports.walk = (root, options, iterator, cb) ->
  if _.isFunction options
    cb = iterator
    iterator = options
    options = {}
  cb ?= ->
  ignoreFolders = options.ignoreFolders || false
  filter = options.filter || -> true

  if _.isString filter
    # if filter is a string, folders shouldn't be passed to the iterator
    # but should be recursed
    ignoreFolders = true
    filter = ((ext) ->
      ext = if ext[0] is '.' then ext else '.' + ext
      (file) -> file.stats.isDirectory() or file.ext == ext
    ) filter

  readdir = (dir, cb) ->
    fs.readdir dir, (err, files) ->
      return cb err if err?
      iter = (file, done) ->
        path = pathutil.join dir, file
        fs.stat path, (err, stats) ->
          return done err if err?
          fobj =
            name: pathutil.basename file
            namenoext: pathutil.basename file, pathutil.extname file
            relpath: pathutil.relative root, path
            path: path
            dirname: pathutil.dirname path
            ext: pathutil.extname file
            stats: stats
          skip = !filter fobj
          if stats.isDirectory()
            if skip
              done()
            else
              readdir path, (err) ->
                return done err if err?
                if ignoreFolders
                  done()
                else
                  iterator fobj, done
          else
            if skip then done() else iterator fobj, done
      async.forEach files, iter, cb

  readdir root, cb
