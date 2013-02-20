async = require 'async'
{stat, readdir} = require 'fs'
{join, basename} = require 'path'

helpers =

    # works like concat, but modifies array
    addTo: (arr, addition) ->
        if Array.isArray addition
            arr.push addition...
        else
            arr.push addition

    # promote elements out of nested arrays
    flatten: (arr) ->
        return arr unless Array.isArray arr

        flattened = []
        for a in arr
            helpers.addTo flattened, a

        return flattened

    # remove null/undefined elements from array
    compact: (arr) ->
        return arr unless Array.isArray arr
        (a for a in arr when a?)

    # walk a directory structure and run processFile on each file
    # always returns an array (or err)
    walk: (options, path, done) ->

        {flatten, compact, walk} = helpers
        {processFile, filter, hidden} = options

        # default options
        filter ||= -> true
        processFile ||= (path) -> path # just return the file names

        return done null, [] if (hidden isnt true) and basename(path).slice(0, 1) is '.'

        dig = (filename, next) ->
            walk options, join(path, filename), next

        recurseDirectory = (dirname, next) ->
            readdir dirname, (err, filenames) ->
                return done err if err
                async.map filenames, dig, (err, data) ->
                    done err, compact(flatten(data))

        # process file or recurse directory
        stat path, (err, stats) =>
            if stats.isDirectory()
                recurseDirectory path, done
            else
                return done null, [] unless filter(path)
                processFile path, (err, data) ->
                    done err, [data] # box in case single file was given

    # break parallel tasks up into chunks
    # NOTE: was going to use this for amazon uploads, but they apparently
    #       don't allow ANY simultaneous uploads
    chunk: (list, iterator, chunkSize=1, done) ->
        return done() if list.length < 1
        async.forEach list.slice(0, chunkSize), iterator, (err) ->
            return done err if err
            helpers.chunk list.slice(chunkSize, -1), iterator, chunkSize, done

module.exports = helpers
