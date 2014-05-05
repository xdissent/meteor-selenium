
Meteor.settings.selenium ?= {}
Meteor.settings.selenium.server ?= {}
Meteor.settings.selenium.chrome ?= {}
Meteor.settings.selenium.browser ?= 'chrome'
Meteor.settings.selenium.enabled ?= true
Meteor.settings.selenium.debug ?= false

chrome_arch = switch process.platform
  when 'linux' then "linux#{if process.arch is 'x64' then 64 else 32}"
  when 'darwin' then 'mac32'
  when 'win32' then 'win32'
  else
    err = "No chrome driver arch for platform #{process.platform}"
    throw new Error err if Meteor.settings.selenium.browser is 'chrome'

chrome_md5 = switch chrome_arch
  when 'linux32' then '1047354165f02aec8ac05f0b0316fe57'
  when 'linux64' then '74de9692467c1c8802711154d66a1859'
  when 'mac32' then '51d2b715138e098d3a417112674cdbaf'
  when 'win32' then '48e6cd44571736de225b078f86909d29'

defaults =
  server:
    md5: '00042f9912c55a6191d7b3fe01239135'
    url: 'http://selenium-release.storage.googleapis.com/2.41/' +
      'selenium-server-standalone-2.41.0.jar'
    port: 4444
  chrome:
    url: 'http://chromedriver.storage.googleapis.com/2.9/' +
      "chromedriver_#{chrome_arch}.zip"
    md5: chrome_md5

_.defaults Meteor.settings.selenium.server, defaults.server
_.defaults Meteor.settings.selenium.chrome, defaults.chrome
