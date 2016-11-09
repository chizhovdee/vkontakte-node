path = require('path')
fs = require('fs')
_ = require('lodash')

configuration = null

loadConfigFromFile = (environment)->
  pathToFile = path.resolve('.', './config')

  configPath = path.join(pathToFile, 'vkontakte.json')

  cn = fs.readFileSync(configPath)

  JSON.parse(cn)[environment || process.env.NODE_ENV]

module.exports =
  default: (environment)->
    configuration ?= _.clone(loadConfigFromFile(environment))
