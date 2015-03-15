AssetGroup = require('./AssetGroup')
config     = require('./config')
fs         = require('fs')


exports.groups = ->
  for name, group of config.data.ASSETS
    new AssetGroup(config.rootPath, group)