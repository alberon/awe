_      = require('lodash')
async  = require('async')
assets = require('./util/assets')
config = require('./util/config')
watch  = require('watch')

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

  triggerCompile = ->
    if running
      runAgain = true
    else
      compileDebounced()

  compile = ->
    running = true
    console.log('Recompiling...')
    console.log('')
    assets.compileGroup(group, compileFinished)

  compileDebounced = _.debounce(compile, 250, maxWait: 1000)

  compileFinished = (err) ->
    throw err if err
    if runAgain
      console.log('')
      console.log('Further changes detected.')
      runAgain = false
      compile()
    else
      running = false
      console.log('')
      console.log('Finished. Watching for further changes...')

  watch.createMonitor group.src, (monitor) ->

    monitor.on 'created', (file, stat) ->
      console.log("Created: #{file}")
      triggerCompile()

    monitor.on 'changed', (file, stat) ->
      console.log("Changed: #{file}")
      triggerCompile()

    monitor.on 'removed', (file, stat) ->
      console.log("Deleted: #{file}")
      triggerCompile()

  console.log("Watching #{group.src}...")
