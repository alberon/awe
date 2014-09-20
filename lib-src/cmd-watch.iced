_      = require('lodash')
async  = require('async')
assets = require('./assets')
config = require('./config')
errTo  = require('errto')
output = require('./output')
watch  = require('node-watch')

exports.run = (command, cb) ->

  # Load config data
  await config.load(errTo(cb, defer()))

  # Create AssetGroup objects
  groups = assets.groups()

  # Initial build
  output.building()
  build = (group, cb) -> group.build(cb)
  await async.each(groups, build, errTo(cb, defer()))

  # Watch for changes
  output.line()
  output.watching()
  async.each(groups, monitor, cb)


monitor = (group, cb) ->
  running = false
  runAgain = false

  build = ->
    output.line()
    output.building()

    running = true
    await group.build(errTo(cb, defer()))
    running = false

    if runAgain
      runAgain = false
      buildDebounced()
    else
      output.finished()
      output.line()

  buildDebounced = _.debounce(build, 250, maxWait: 1000)

  watch group.srcPath, (file) ->
    output.modified(file)
    if running
      runAgain = true
    else
      buildDebounced()
