
SeleniumRemote = Npm.require 'selenium-webdriver/remote'


class Selenium.Server.Local extends Selenium.Server

  constructor: (@file, @args, _args...) ->
    super _args...
    @_server = new SeleniumRemote.SeleniumServer @file, port: @port, args: @args

  _start: (callback) ->
    @_server.start().then (url) ->
      callback()
    , callback

  _stop: (callback) ->
    @_server.start().then ->
      callback()
    , callback
