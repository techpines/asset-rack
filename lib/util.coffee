
EventEmitter = require('events').EventEmitter
Buffer = require('buffer').Buffer
_ = require 'underscore'

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

exports.extend = (object) ->
    class Asset extends this
    for key, value of object
        Asset::[key] = value
    Asset
