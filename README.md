selenium
========


Meteor Settings
---------------

```coffee
selenium:

  # Enable selenium package
  enabled: true

  # Print debug messages
  debug: false

  # Browser to use for WebDriverJS driver
  browser: 'chrome'
  
  server:

    # Sever URL settings
    proto: 'http'
    host: 'localhost'
    port: 4444
    path: 'wd/hub'

    # Enable chrome support on the server
    chrome: true

    # Locally controlled server (whether can be start/stopped)
    local: true

    # Arguments passed to java for local servers
    args: ['-Dwebdriver.chrome.driver=.meteor/local/selenium-chrome']

    # Start server when starting up app
    start: true

    # Download the server jar if required
    download: true

    # The url from which to download the server jar
    url: 'http://url.to/selenium-server.jar'

    # The local path to which the server jar will be saved
    file: '.meteor/local/selenium.jar'

    # The md5 hash of the server jar
    md5: '###'

  chrome:

    # Download chromedriver if required
    download: true

    # The url from which to download chromedriver
    url: 'http://url.to/selenium-chromedriver.zip'

    # The local path to which chromedriver will be saved
    file: '.meteor/local/selenium-chrome'

    # The md5 hash of chromedriver
    md5: '###'
```