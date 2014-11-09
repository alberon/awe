async  = require('async')
assets = require('./assets')
config = require('./config')
errTo  = require('errto')
output = require('./output')


exports.run = (command, cb) ->

  # Load config data
  await config.load(errTo(cb, defer()))

  # Create AssetGroup objects
  groups = assets.groups()

  # Build assets
  output.building()
  build = (group, cb) -> group.build(cb)
  await async.each(groups, build, errTo(cb, defer()))

  # Finished
  output.finished()
