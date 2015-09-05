AssetGroup = require('./AssetGroup')
config     = require('./config')


exports.groups = ->
  for name, group of config.data.ASSETS
    new AssetGroup(config.rootPath, group)
