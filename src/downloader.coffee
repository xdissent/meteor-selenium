
fs = Npm.require 'fs'
crypto = Npm.require 'crypto'
http = Npm.require 'http'

debug = ->
  console.log 'Selenium Downloader -', arguments... if Selenium.settings.debug


class Selenium.Downloader

  constructor: (@url, @file, @hash) ->

  download: (callback) -> @_download Meteor.bindEnvironment callback

  downloadSync: -> Meteor._wrapAsync((callback) => @_download callback)()

  _download: (callback) ->
    @_check (err, matches, hash) =>
      return callback() if matches
      debug "Hash mismatch for #{@file} expecting #{@hash} got #{hash}"
      @_fetch (err) =>
        return callback err if err?
        debug "Download of #{@file} complete"
        @_check (err, matches, hash) =>
          return callback() if matches
          debug "Hash mismatch for #{@file} expecting #{@hash} got #{hash}"
          callback new Error 'Hash check failed'

  _check: (callback) ->
    debug "Checking hash for #{@file} expecting #{@hash}"
    hash = crypto.createHash 'md5'
    stream = fs.ReadStream @file
    stream.on 'data', (data) -> hash.update data
    stream.on 'error', callback
    stream.on 'end', =>
      digest = hash.digest 'hex'
      callback null, @hash is digest, digest

  _request: (callback) ->
    req = http.request @url, (res) ->
      return callback null, res if res.statusCode is 200
      callback new Error "Bad status #{res.statusCode}"
    req.once 'error', -> callback new Error 'Failed to request download'
    req.end()

  _fetch: (callback) ->
    debug "Downloading #{@file} from #{@url}"
    @_request (err, stream) =>
      return callback err if err?
      @_save stream, callback

  _save: (stream, callback) =>
    callback = _.once callback
    stream.pipe fs.createWriteStream @file
      .once 'error', -> callback new Error 'Failed to save download'
      .once 'finish', callback
