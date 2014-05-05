
path = Npm.require 'path'

settings = share.settings = _.clone(Meteor.settings.selenium) ? {}
settings.server = _.clone(Meteor.settings.selenium?.server) ? {}
settings.chrome = _.clone(Meteor.settings.selenium?.chrome) ? {}

_.defaults settings,
  browser: 'chrome'
  enabled: true
  debug: false

local_path = path.join process.env.PWD, '.meteor/local'
chrome_ext = if process.platform is 'win32' then '.exe' else ''

chrome_arch = switch process.platform
  when 'linux' then "linux#{if process.arch is 'x64' then 64 else 32}"
  when 'darwin' then 'mac32'
  when 'win32' then 'win32'
  else
    err = "No chrome driver arch for platform #{process.platform}"
    throw new Error err if settings.browser is 'chrome'

chrome_md5 = switch chrome_arch
  when 'linux32' then '1047354165f02aec8ac05f0b0316fe57'
  when 'linux64' then '74de9692467c1c8802711154d66a1859'
  when 'mac32' then '51d2b715138e098d3a417112674cdbaf'
  when 'win32' then '48e6cd44571736de225b078f86909d29'

_.defaults settings.server,
  md5: '00042f9912c55a6191d7b3fe01239135'
  url: 'http://selenium-release.storage.googleapis.com/2.41/' +
    'selenium-server-standalone-2.41.0.jar'
  port: 4444
  path: path.join local_path, 'selenium-server.jar'
  download: not settings.server.addr? and not settings.server.path?
  start: not settings.server.addr?

_.defaults settings.chrome,
  url: 'http://chromedriver.storage.googleapis.com/2.9/' +
    "chromedriver_#{chrome_arch}.zip"
  md5: chrome_md5
  path: path.join local_path, "selenium-chrome#{chrome_ext}"
  download: settings.browser is 'chrome' and not settings.server.addr? and
    not settings.chrome.path?

settings.server.args ?= if settings.browser is 'chrome'
  ["-Dwebdriver.chrome.driver=#{settings.chrome.path}"]
else []

settings.server.addr ?= "http://localhost:#{settings.server.port}/wd/hub"
