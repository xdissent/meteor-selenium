
join = Npm.require('path').join


class Selenium.Server

  constructor: (
    @host = 'localhost'
    @port = 4444
    @proto = 'http'
    @path = 'wd/hub'
  ) ->
    @path = "/#{@path}" unless @path[0] is '/'
    @url = "#{@proto}://#{@host}:#{@port}#{@path}"
  
  start: (callback) -> @_start Meteor.bindEnvironment callback

  startSync: -> Meteor._wrapAsync((callback) => @_start callback)()

  _start: (callback) -> callback()

  stop: (callback) -> @_stop Meteor.bindEnvironment callback

  stopSync: -> Meteor._wrapAsync((callback) => @_stop callback)()

  _stop: (callback) -> callback()
