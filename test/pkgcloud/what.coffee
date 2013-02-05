
fs = require 'fs'
pkgcloud = require 'pkgcloud'
aws = require('/etc/techpines/aws')
Buffer = require('buffer').Buffer
EventEmitter = require('events').EventEmitter
        
class BufferStream extends EventEmitter
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

client = pkgcloud.storage.createClient
    key: aws.secret
    keyId: aws.key
    provider: 'amazon'

stream = new BufferStream fs.readFileSync('./what.coffee')

client.upload
    container: 'temp.techpines.com'
    remote: 'what.coffee'
    stream: stream
, ->
    console.log 'done'

