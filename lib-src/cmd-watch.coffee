_      = require('lodash')
async  = require('async')
assets = require('./assets')
config = require('./config')
output = require('./output')
watch  = require('node-watch')

exports.run = (command) ->
  async.auto

    # Load config file
    config: config.load

    # Create AssetGroup objects
    groups: ['config', (cb) ->
      cb(null, assets.groups())
    ]

    # Initial build
    build: ['groups', (cb, results) ->
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

  watch group.srcPath, (file) ->
    output.modified(file)
    if running
      runAgain = true
    else
      buildDebounced()

  cb()
