
fs = Npm.require 'fs'
crypto = Npm.require 'crypto'
http = Npm.require 'http'
unzip = Npm.require 'unzip'

debug = (args...) ->
  if Meteor.settings.selenium.debug
    console.log 'Selenium Downloader - ', args...


share.Downloader = class Downloader
  constructor: (@settings, @server_path, @chrome_path) ->

  server: (callback) ->
    return callback null if @settings.server.path?
    @_checkAndDownload @settings.server.url, @server_path, @settings.server.md5,
      callback

  chrome: (callback) ->
    if @settings.chrome.path? or @settings.browser isnt 'chrome'
      return callback null
    @_checkAndDownload @settings.chrome.url, @chrome_path, @settings.chrome.md5,
      (err) => if err? then callback err else @_chmodChrome callback

  _checkHash: (file, hash, callback) ->
    debug "Checking hash for #{file} expecting #{hash}"
    file_hash = crypto.createHash 'md5'
    stream = fs.ReadStream file
    stream.on 'data', (data) -> file_hash.update data
    stream.on 'end', -> callback null, hash is file_hash.digest 'hex'
    stream.on 'error', callback

  _request: (url, callback) ->
    req = http.request url, (res) ->
      return callback null, res if res.statusCode is 200
      callback new Error "Bad status #{res.statusCode}"
    req.once 'error', (err) -> callback
    req.end()

  _download: (url, file, hash, callback) ->
    debug "Downloading #{file} from #{url} with hash #{hash}"
    @_request url, (err, stream) ->
      return callback err if err?
      called = false
      cb = ->
        callback arguments... unless called
        called = true
      save = (stream) ->
        stream.pipe fs.createWriteStream file
          .once 'error', -> cb new Error 'Failed to save download'
          .once 'finish', cb
      return save stream unless /\.zip$/.test url
      stream.pipe unzip.Parse()
        .once 'entry', save
        .once 'error', cb

  _checkAndDownload: (url, file, hash, callback) ->
    @_checkHash file, hash, (err, matches) =>
      return callback null if matches
      debug "Hash mismatch for #{file}"
      @_download url, file, hash, (err) =>
        return callback err if err?
        debug "Download of #{file} complete"
        @_checkHash file, hash, (err, matches) ->
          return callback null if matches
          callback new Error "Hash mismatch for #{file}"

  _chmodChrome: (callback) ->
    return callback null if process.platform is 'win32'
    fs.chmod @chrome_path, 0o755, callback
