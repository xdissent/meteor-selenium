
Package.describe({
  summary: 'Selenium WebDriverJS and standalone server controller'
});

Npm.depends({
  'selenium-webdriver': '2.41.0',
  'unzip': '0.1.9'
});

Package.on_use(function (api, where) {
  api.use(['underscore', 'coffeescript'], 'server');
  api.add_files('src/settings.coffee', 'server');
  api.add_files('src/builder.coffee', 'server');
  api.add_files('src/downloader.coffee', 'server');
  api.add_files('src/main.coffee', 'server');
  api.export('Selenium', 'server');
});
