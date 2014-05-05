
path = Npm.require 'path'
webdriver = Npm.require 'selenium-webdriver'
SeleniumRemote = Npm.require 'selenium-webdriver/remote'

debug = (args...) ->
  console.log 'Selenium -', args... if share.settings.debug


class MeteorSelenium

  webdriver: webdriver
  Builder: share.Builder
  Downloader: share.Downloader
  settings: share.settings

  @init: ->
    return {} unless share.settings.enabled
    new MeteorSelenium

  constructor: -> Meteor._wrapAsync(@init.bind this)()

  init: (callback) ->
    debug 'Initializing'
    downloader = new @Downloader
    downloader.server (err) =>
      return callback err if err?
      downloader.chrome (err) =>
        return callback err if err?
        @_startServer (err) =>
          return callback err if err?
          @_buildDriver callback

  _startServer: (callback) ->
    return callback null unless @settings.server.start
    debug 'Starting server'
    @server = new SeleniumRemote.SeleniumServer @settings.server.path,
      port: @settings.server.port, args: @settings.server.args
    @server.start().then (url) ->
      debug 'Server started', url
      callback null
    , (err) ->
      debug 'Error starting server', err
      callback err

  _buildDriver: (callback) ->
    try
      capabilities = webdriver.Capabilities[@settings.browser]()
    catch err
      debug 'Error getting capabilities', err
      return callback err
    try
      @driver = new @Builder()
        .usingServer @settings.server.addr
        .withCapabilities capabilities
        .build()
    catch err
      debug 'Error building driver', err
      return callback err
    callback null


Selenium = MeteorSelenium.init()
