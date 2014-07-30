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
  watch.createMonitor group.src, (monitor) ->

    monitor.on 'created', (file, stat) ->
      console.log("Created: #{file}")
      compile(group)

    monitor.on 'changed', (file, stat) ->
      console.log("Changed: #{file}")
      compile(group)

    monitor.on 'removed', (file, stat) ->
      console.log("Deleted: #{file}")
      compile(group)

  console.log("Watching #{group.src}...")

compile = (group) ->
  console.log('Recompiling...')
  console.log('')
  assets.compileGroup group, (err) ->
    throw err if err
    console.log('')
    console.log('Finished. Watching for further changes...')
