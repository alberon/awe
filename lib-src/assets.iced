AssetGroup = require('./AssetGroup')
config     = require('./config')
fs         = require('fs')


exports.groups = ->
  for name, group of config.data.assets
    new AssetGroup(group)
