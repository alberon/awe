async  = require('async')
assets = require('./util/assets')
config = require('./util/config')
log    = require('./util/log')

exports.run = (command) ->
  async.auto

    # Locate config file
    config: (cb) ->
      config.load(cb)

    # Prepare the required directories
    prepare: ['config', (cb, results) ->
      assets.prepare(results.config.root, cb)
    ]

    # Build assets
    build: ['prepare', (cb, results) ->
      log.building()
      groups = (group for name, group of results.config.data.assets)
      async.each(groups, assets.buildGroup, cb)
    ]

    # Finished
    finished: ['build', (cb, results) ->
      log.finished()
    ]

    # Error handler
    (err) -> throw err if err
