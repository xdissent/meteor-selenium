
path = Npm.require 'path'
webdriver = Npm.require 'selenium-webdriver'

debug = -> console.log 'Selenium -', arguments... if Selenium.settings.debug


class Selenium

  @webdriver: webdriver

  @driver: (url = @server?.url, browser = @settings.browser) ->
    @Driver.build url, browser

  @_init: ->
    debug 'Settings', @settings
    return unless @settings.enabled
    @_initDownloaders()
    @_initServer()

  @_initDownloaders: ->
    @downloaders =
      server: new @Downloader.Server @settings.server.url,
        @settings.server.file, @settings.server.md5
      chrome: new @Downloader.Chrome @settings.chrome.url,
        @settings.chrome.file, @settings.chrome.md5
    dl.downloadSync() for name, dl of @downloaders when @settings[name].download

  @_initServer: ->
    Server = if @settings.server.local then @Server.Local else @Server.Remote
    args = [
      @settings.server.host
      @settings.server.port
      @settings.server.proto
      @settings.server.path
    ]
    if @settings.server.local
      args = [@settings.server.file, @settings.server.args].concat args
    @server = new Server args...
    @server.startSync() if @settings.server.start
