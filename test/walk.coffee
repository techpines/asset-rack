should = require('chai').should()
{join} = require 'path'
{walk} = require('../.').util

describe 'util.walk', ->
    app = null
    fixtures = join __dirname, 'fixtures/walk'
    numberOfFilesAndFolders = 26
    numberOfFiles = 18
    numberOfFilesWithExt = 3

    it 'should work', (done) ->
        count = 0
        walk fixtures, {}, (file, done) ->
            count++
            done()
          , ->
            count.should.equal numberOfFilesAndFolders
            done()

    it 'should work with ignoreFolders option', (done) ->
        count = 0
        walk fixtures, ignoreFolders: true, (file, done) ->
            count++
            done()
          , ->
            count.should.equal numberOfFiles
            done()

    it 'should work with filter', (done) ->
        count = 0
        walk fixtures, filter: 'ext', (file, done) ->
            count++
            done()
          , ->
            count.should.equal numberOfFilesWithExt
            done()

    it 'should work without passing options', (done) ->
        count = 0
        walk fixtures, (file, done) ->
            count++
            done()
          , ->
            count.should.equal numberOfFilesAndFolders
            done()

    it 'should work without passing a callback', (doneTest) ->
        count = 0
        walk fixtures, {}, (file, done) ->
            done()
            doneTest() if ++count is numberOfFilesAndFolders

    it 'should work without passing options or a callback', (doneTest) ->
        count = 0
        walk fixtures, (file, done) ->
            done()
            doneTest() if ++count is numberOfFilesAndFolders
