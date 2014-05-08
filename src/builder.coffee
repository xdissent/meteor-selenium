
webdriver = Npm.require 'selenium-webdriver'
SeleniumRemote = Npm.require 'selenium-webdriver/remote'
SeleniumExecutors = Npm.require 'selenium-webdriver/executors.js'
SeleniumChrome = Npm.require 'selenium-webdriver/chrome.js'
SeleniumPortProber = Npm.require 'selenium-webdriver/net/portprober.js'
SeleniumIO = Npm.require 'selenium-webdriver/io'

debug = -> console.log 'Selenium -', arguments... if Selenium.settings.debug


class Selenium.Builder extends webdriver.Builder

  _getPhantomJSArgs: -> @getCapabilities().get('phantomjs.cli.args') or []

  _getPhantomJSPath: ->
    exe = @getCapabilities().get 'phantomjs.binary.path'
    return exe if exe?
    exe = if process.platform is 'win32' then 'phantomjs.exe' else 'phantomjs'
    exe = SeleniumIO.findInPath exe, true
    return exe if exe?
    throw new Error 'Could not find PhantomJS executable'

  _getPhantomJSService: ->
    args = @_getPhantomJSArgs()
    new SeleniumRemote.DriverService @_getPhantomJSPath(),
      port: SeleniumPortProber.findFreePort()
      args: webdriver.promise.when port, (port) ->
        args.concat ["--webdriver=#{port}"]

  _getService: ->
    url = @getServerUrl()
    return url if url?
    switch @getCapabilities().get webdriver.Capability.BROWSER_NAME
      when webdriver.Browser.CHROME
        SeleniumChrome.getDefaultService().start()
      when webdriver.Browser.PHANTOM_JS then @_getPhantomJSService().start()
      else webdriver.AbstractBuilder.DEFAULT_SERVER_URL

  _getCapabilities: ->
    switch @getCapabilities().get webdriver.Capability.BROWSER_NAME
      when webdriver.Browser.CHROME
        SeleniumChrome.Options.fromCapabilities @getCapabilities()
          .toCapabilities()
      else @getCapabilities()

  _getExecutor: -> SeleniumExecutors.createExecutor @_getService()

  _getSession: (executor) ->
    webdriver.promise.controlFlow().execute =>
      command = new webdriver.Command webdriver.CommandName.GET_SESSIONS
      Selenium.Driver.executeCommand_(executor, command).then (res) =>
        throw new Error 'Selenium get sessions failed' unless res?.status is 0
        if res.value.length > 0
          session_id = res.value[0].id
          capabilities = res.value[0].capabilities
          capabilities['webdriver.remote.sessionid'] = session_id
          debug 'Resuming session', session_id
          return new webdriver.Session session_id, capabilities
        debug 'Creating session'
        command = new webdriver.Command webdriver.CommandName.NEW_SESSION
          .setParameter 'desiredCapabilities', @_getCapabilities()
        Selenium.Driver.executeCommand_(executor, command).then (res) ->
          unless res?.status is 0
            throw new Error 'Selenium create session failed'
          new webdriver.Session res.sessionId, res.value
    , 'Selenium.Builder._getSession()'

  build: ->
    debug 'Building driver'
    executor = @_getExecutor()
    session = @_getSession executor
    new Selenium.Driver session, executor
