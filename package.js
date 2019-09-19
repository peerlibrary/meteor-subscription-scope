Package.describe({
  name: 'peerlibrary:subscription-scope',
  summary: "Scope queries on collections to subscriptions",
  version: '0.4.0',
  git: 'https://github.com/peerlibrary/meteor-subscription-scope.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.6.1.3');

  // Core dependencies.
  api.use([
    'coffeescript',
    'ecmascript',
    'underscore',
    'minimongo'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:extend-publish@0.5.0'
  ]);

  api.addFiles([
    'server.coffee'
  ], 'server');

  api.addFiles([
    'client.coffee'
  ], 'client');
});

Package.onTest(function (api) {
  api.versionsFrom('METEOR@1.6.1.3');

  // Core dependencies.
  api.use([
    'coffeescript',
    'ecmascript',
    'random',
    'underscore',
    'mongo'
  ]);

  // Internal dependencies.
  api.use([
    'peerlibrary:subscription-scope'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:classy-test@0.3.0'
  ]);

  api.addFiles([
    'tests.coffee'
  ]);
});
