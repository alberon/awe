_      = require('lodash')
async  = require('async')
assets = require('./util/assets')
config = require('./util/config')
log    = require('./util/log')
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

    # Initial build
    build: ['prepare', (cb, results) ->
      log.building()
      groups = (group for name, group of results.config.data.assets)
      async.each(groups, assets.buildGroup, cb)
    ]

    # Watch for changes
    watch: ['build', (cb, results) ->
      console.log('')
      log.watching()
      groups = (group for name, group of results.config.data.assets)
      async.each(groups, monitor, cb)
    ]

    # Error handler
    (err) -> throw err if err

monitor = (group, cb) ->
  running = false
  runAgain = false

  build = ->
    running = true
    console.log('')
    log.building()
    assets.buildGroup(group, buildFinished)

  buildDebounced = _.debounce(build, 250, maxWait: 1000)

  buildFinished = (err) ->
    throw err if err
    running = false

    if runAgain
      runAgain = false
      buildDebounced()
    else
      log.finished()
      console.log('')

  watch group.src, (file) ->
    log.modified(file)
    if running
      runAgain = true
    else
      buildDebounced()

  cb()
