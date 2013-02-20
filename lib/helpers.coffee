async = require 'async'
{stat, readdir} = require 'fs'
{join} = require 'path'

helpers =
    walk: (dirname, processFile, done) ->

        recurseOrProcess = (filename, next) =>
            return next() if filename.slice(0, 1) is '.'
            path = join dirname, filename
            stat path, (err, stats) =>
                if stats.isDirectory()
                    @walk path, processFile, next
                else
                    processFile path, next

        readdir dirname, (err, filenames) ->
            return done err if err
            async.map filenames, recurseOrProcess, done

module.exports = helpers
