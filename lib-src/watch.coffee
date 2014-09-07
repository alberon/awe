_      = require('lodash')
async  = require('async')
assets = require('./util/assets')
config = require('./util/config')
output = require('./util/output')
watch  = require('node-watch')

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

    # Initial build
    build: ['prepare', 'groups', (cb, results) ->
      output.building()
      build = (group, cb) -> group.build(cb)
      async.each(results.groups, build, cb)
    ]

    # Watch for changes
    watch: ['build', (cb, results) ->
      output.line()
      output.watching()
      async.each(results.groups, monitor, cb)
    ]

    # Error handler
    (err) -> throw err if err

monitor = (group, cb) ->
  running = false
  runAgain = false

  build = ->
    running = true
    output.line()
    output.building()
    group.build(buildFinished)

  buildDebounced = _.debounce(build, 250, maxWait: 1000)

  buildFinished = (err) ->
    throw err if err
    running = false

    if runAgain
      runAgain = false
      buildDebounced()
    else
      output.finished()
      output.line()

  watch group.src, (file) ->
    output.modified(file)
    if running
      runAgain = true
    else
      buildDebounced()

  cb()
