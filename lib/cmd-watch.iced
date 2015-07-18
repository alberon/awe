_      = require('lodash')
async  = require('async')
assets = require('./assets')
config = require('./config')
errTo  = require('errto')
output = require('./output')
path   = require('path')
watch  = require('node-watch')


exports.run = (command, errCb) ->

  stdin = process.stdin

  # Load config data
  await config.load(errTo(errCb, defer()))

  # Create AssetGroup objects
  groups = assets.groups()

  # Watch for changes
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
      # Using errCb directly because we can't call cb() more than once
      await group.build(errTo(errCb, defer()))
      running = false
      numRunning--

      if runAgain
        runAgain = false
        buildDebounced()
      else if numRunning == 0
        output.finished()
        output.line()
        if stdin.setRawMode
          output.watchingWithInput()
        else
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

  await async.map(groups, watchGroup, errTo(errCb, defer watches))

  # Listen for keyboard input
  if stdin.setRawMode
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
