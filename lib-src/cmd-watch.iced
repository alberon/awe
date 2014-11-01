_      = require('lodash')
async  = require('async')
assets = require('./assets')
config = require('./config')
errTo  = require('errto')
output = require('./output')
path   = require('path')
watch  = require('node-watch')


exports.run = (command, cb) ->

  # Load config data
  await config.load(errTo(cb, defer()))

  # Create AssetGroup objects
  groups = assets.groups()

  # Watch for changes
  await async.map(groups, watchGroup, errTo(cb, defer watches))

  # Listen for keyboard input
  stdin = process.stdin

  stdin.setRawMode(true)
  stdin.setEncoding('utf8')
  stdin.resume()

  stdin.on 'data', (key) ->
    if key == 'q' || key == 'Q' || key == '\u0003' # Ctrl-C
      # Quit
      process.exit()

    else if key == 'b' || key == 'B'
      # Build all
      for watcher in watches
        watcher.build()


numRunning = 0

watchGroup = (group, cb) ->
  running = true
  runAgain = false

  # Build
  build = ->
    if numRunning == 0
      output.line()
      output.building()

    running = true
    numRunning++
    await group.build(errTo(cb, defer()))
    running = false
    numRunning--

    if runAgain
      runAgain = false
      buildDebounced()
    else if numRunning == 0
      output.finished()
      output.line()
      output.watching()

  # Wait 250ms in case multiple files are saved at once
  buildDebounced = _.debounce(build, 250, maxWait: 1000)

  # Manual build (triggered by user)
  manualBuild = ->
    if running
      runAgain = true
    else
      build()

  # Watch for changes
  watch group.srcPath, (file) ->
    output.modified(path.relative(config.rootPath, file))
    if running
      runAgain = true
    else
      buildDebounced()

  # Start initial build
  build()

  # Return build function so it can be called manually
  cb(null, build: manualBuild)
