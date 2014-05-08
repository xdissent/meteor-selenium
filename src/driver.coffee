
webdriver = Npm.require 'selenium-webdriver'


class Selenium.Driver extends webdriver.WebDriver

  @build: (url, browser) ->
    new Selenium.Builder()
      .usingServer url
      .withCapabilities webdriver.Capabilities[browser]()
      .build()
