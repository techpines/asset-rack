
EventEmitter = require('events').EventEmitter
Buffer = require('buffer').Buffer

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
