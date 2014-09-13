async  = require('async')
assets = require('./assets')
config = require('./config')
output = require('./output')

exports.run = (command) ->
  async.auto

    # Load config file
    config: config.load

    # Create AssetGroup objects
    groups: ['config', (cb) ->
      cb(null, assets.groups())
    ]

    # Build assets
    build: ['groups', (cb, results) ->
      output.building()
      build = (group, cb) -> group.build(cb)
      async.each(results.groups, build, cb)
    ]

    # Finished
    finished: ['build', (cb, results) ->
      output.finished()
    ]

    # Error handler
    (err) -> throw err if err
