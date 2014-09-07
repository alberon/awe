async  = require('async')
assets = require('./util/assets')
config = require('./util/config')
output = require('./util/output')

exports.run = (command) ->
  async.auto

    # Locate config file
    config: (cb) ->
      config.load(cb)

    # Prepare the required directories
    prepare: ['config', (cb, results) ->
      assets.prepare(results.config.root, cb)
    ]

    # Create objects
    groups: ['config', (cb, results) ->
      cb(null, new assets.AssetGroup(group) for name, group of results.config.data.assets)
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
