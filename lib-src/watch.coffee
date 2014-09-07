_      = require('lodash')
async  = require('async')
assets = require('./util/assets')
config = require('./util/config')
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

    # Watch for changes
    watch: ['prepare', (cb, results) ->
      for name, group of results.config.data.assets
        monitor(group)
    ]

    # Error handler
    (err) -> throw err if err

monitor = (group) ->
  running = false
  runAgain = false

  compile = ->
    running = true
    console.log('Recompiling...')
    console.log('')
    assets.compileGroup(group, compileFinished)

  compileDebounced = _.debounce(compile, 250, maxWait: 1000)

  compileFinished = (err) ->
    throw err if err
    running = false

    if runAgain
      console.log('')
      console.log('Further changes detected.')
      runAgain = false
      compileDebounced()
    else
      console.log('')
      console.log('Finished. Watching for further changes...')

  watch group.src, (file) ->
    console.log("Created: #{file}")
    if running
      runAgain = true
    else
      compileDebounced()

  console.log("Watching #{group.src}...")
