
fs = Npm.require 'fs'
unzip = Npm.require 'unzip'


class Selenium.Downloader.Chrome extends Selenium.Downloader

  _download: (callback) ->
    super (err) => if err? then callback err else @_chmod callback

  _save: (stream, callback) ->
    callback = _.once callback
    _super = @constructor.__super__._save
    stream.pipe unzip.Parse()
      .once 'error', callback
      .once 'entry', (stream) => _super.call this, stream, callback

  _chmod: (callback) ->
    return callback() if process.platform is 'win32'
    fs.chmod @file, 0o755, callback
