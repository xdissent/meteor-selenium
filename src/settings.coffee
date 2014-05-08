
# Default settings:
#
# browser: 'chrome'
# enabled: true
# debug: false
# server:
#   chrome: true
#   proto: 'http'
#   host: 'localhost'
#   port: 4444
#   path: 'wd/hub'
#   local: true
#   start: true
#   download: true
#   url: 'http://url.to/selenium-server.jar'
#   file: '.meteor/local/selenium.jar'
#   md5: '###'
# chrome:
#   download: true
#   url: 'http://url.to/selenium-chromedriver.zip'
#   file: '.meteor/local/selenium-chrome'
#   md5: '###'

path = Npm.require 'path'

local_path = path.join process.env.PWD, '.meteor/local'

settings = Selenium.settings = _.clone Meteor.settings.selenium ? {}
settings.server = server = _.clone settings.server ? {}
settings.chrome = chrome = _.clone settings.chrome ? {}

settings.enabled ?= true
settings.debug ?= false

_.defaults server,
  proto: 'http'
  host: 'localhost'
  port: 4444
  path: 'wd/hub'
  url: 'http://selenium-release.storage.googleapis.com/2.41/' +
    'selenium-server-standalone-2.41.0.jar'
  file: path.join local_path, 'selenium-server.jar'
  md5: '00042f9912c55a6191d7b3fe01239135'

server.local ?= server.file? and server.host in ['localhost', '127.0.0.1']
server.download ?= server.local
server.start ?= server.local
server.chrome ?= server.local

settings.browser ?= 'phantomjs' if server.local and not server.chrome
settings.browser ?= 'chrome'

chrome.download ?= server.local and server.chrome

chrome_ext = if process.platform is 'win32' then '.exe' else ''

chrome.file ?= path.join local_path, "selenium-chrome#{chrome_ext}"

chrome_arch = switch process.platform
  when 'linux' then "linux#{if process.arch is 'x64' then 64 else 32}"
  when 'darwin' then 'mac32'
  when 'win32' then 'win32'
  else
    if not chrome.url? or not chrome.md5? and chrome.download
      throw new Error "No chrome driver arch for platform #{process.platform}"

chrome.md5 ?= switch chrome_arch
  when 'linux32' then '1047354165f02aec8ac05f0b0316fe57'
  when 'linux64' then '74de9692467c1c8802711154d66a1859'
  when 'mac32' then '51d2b715138e098d3a417112674cdbaf'
  when 'win32' then '48e6cd44571736de225b078f86909d29'

chrome.url ?= 'http://chromedriver.storage.googleapis.com/2.9/' +
  "chromedriver_#{chrome_arch}.zip" if chrome_arch?

server.args ?= if server.chrome
  ["-Dwebdriver.chrome.driver=#{chrome.file}"]
else []
