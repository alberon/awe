async  = require('async')
assets = require('./assets')
config = require('./config')
output = require('./output')

exports.run = (command) ->
  async.auto

    # Locate config file
    config: (cb) ->
      config.load(cb)

    # Prepare the required directories
    prepare: ['config', (cb, results) ->
      assets.prepare(config.rootDir, cb)
    ]

    # Create objects
    groups: ['prepare', (cb, results) ->
      cb(null, new assets.AssetGroup(group) for name, group of config.data.assets)
    ]

    # Build assets
    build: ['prepare', 'groups', (cb, results) ->
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
