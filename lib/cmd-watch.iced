_        = require('lodash')
async    = require('async')
assets   = require('./assets')
chokidar = require('chokidar')
config   = require('./config')
errTo    = require('errto')
fs       = require('fs')
output   = require('./output')
path     = require('path')


exports.run = (command, errCb) ->

  await
    # Load config data
    config.load(errTo(errCb, defer()))

    # Determine if we're running Vagrant (best guess)
    fs.stat('/vagrant', defer(vagrantErr, vagrantStat))

  # Is this Vagrant? If so we have to use polling not inotify to detect changes
  isVagrant = !vagrantErr && vagrantStat.isDirectory()
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
    changed = (file) ->
      output.modified(path.relative(config.rootPath, file))
      if running
        runAgain = true
      else
        buildDebounced()

    chokidar.watch(group.srcPath, usePolling: isVagrant, ignoreInitial: true)
      .on('add', changed)
      .on('change', changed)
      .on('unlink', changed)
      .on('addDir', changed)
      .on('unlinkDir', changed)

    # Start initial build
    build()

    # Return build function so it can be called manually
    cb(null, build: manualBuild)

  await async.map(groups, watchGroup, errTo(errCb, defer watches))

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
