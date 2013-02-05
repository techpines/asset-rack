
fs = require 'fs'
pkgcloud = require 'pkgcloud'
aws = require('/etc/techpines/aws')
Stream = new require('stream')
stream = new Stream()
console.log(stream)
        

client = pkgcloud.storage.createClient
    key: aws.secret
    keyId: aws.key
    provider: 'amazon'

client.upload
    container: 'temp.techpines.com'
    remote: 'what.coffee'
    stream: stream
, ->
    console.log 'done'

stream.end new Buffer('cheese wiz')
