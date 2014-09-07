async  = require('async')
assets = require('./util/assets')
config = require('./util/config')

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
      groups = (group for name, group of results.config.data.assets)
      async.each(groups, assets.buildGroup, cb)
    ]

    # Error handler
    (err) -> throw err if err
