
path = Npm.require 'path'
webdriver = Npm.require 'selenium-webdriver'
SeleniumRemote = Npm.require 'selenium-webdriver/remote'

debug = (args...) ->
  console.log 'Selenium - ', args... if Meteor.settings.selenium.debug


class MeteorSelenium
  webdriver: webdriver
  Builder: share.Builder
  Downloader: share.Downloader

  local_path: path.join process.env.PWD, '.meteor/local'

  @init: ->
    return {} unless Meteor.settings.selenium.enabled
    new MeteorSelenium Meteor.settings.selenium

  constructor: (@settings) -> Meteor._wrapAsync(@init.bind this)()

  serverPath: ->
    @settings.server.path ? path.join @local_path, 'selenium-server.jar'

  chromePath: ->
    ext = if process.platform is 'win32' then '.exe' else ''
    @settings.chrome.path ? path.join @local_path, "selenium-chrome#{ext}"

  _serverArgs: ->
    @settings.server.args ? if @settings.browser is 'chrome'
      ["-Dwebdriver.chrome.driver=#{@chromePath()}"]
    else []

  _serverAddr: -> @settings.server.remote ? @server?.address()
  
  init: (callback) ->
    debug 'Initializing'
    downloader = new @Downloader @settings, @serverPath(), @chromePath()
    downloader.server (err) =>
      return callback err if err?
      downloader.chrome (err) =>
        return callback err if err?
        @_startServer (err) =>
          return callback err if err?
          @_buildDriver callback

  _startServer: (callback) ->
    return callback null if @settings.server.remote?
    debug 'Starting server'
    @server = new SeleniumRemote.SeleniumServer @serverPath(),
      port: @settings.server.port, args: @_serverArgs()
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
        .usingServer @_serverAddr()
        .withCapabilities capabilities
        .build()
    catch err
      debug 'Error building driver', err
      return callback err
    callback null


Selenium = MeteorSelenium.init()
