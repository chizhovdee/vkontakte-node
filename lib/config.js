// Generated by CoffeeScript 1.10.0
(function() {
  var _, configuration, fs, loadConfigFromFile, path;

  path = require('path');

  fs = require('fs');

  _ = require('lodash');

  configuration = null;

  loadConfigFromFile = function(environment) {
    var cn, configPath, pathToFile;
    pathToFile = path.resolve('.', './config');
    configPath = path.join(pathToFile, 'vkontakte.json');
    cn = fs.readFileSync(configPath);
    return JSON.parse(cn)[environment || process.env.NODE_ENV];
  };

  module.exports = {
    "default": function(environment) {
      return configuration != null ? configuration : configuration = _.clone(loadConfigFromFile(environment));
    }
  };

}).call(this);