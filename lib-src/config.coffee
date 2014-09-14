async     = require('async')
chalk     = require('chalk')
findup    = require('findup')
fs        = require('fs')
normalise = require('./normaliseConfig')
path      = require('path')
yaml      = require('js-yaml')

config          = module.exports
config.filename = 'awe.yaml'
config.loaded   = false
config.data     = null
config.rootPath = null

# For unit tests
config.cwd       = process.cwd()
config.normalise = normalise

config.load = (cb) ->
  return cb() if config.loaded

  async.auto

    locateConfigFile: (cb) ->
      findup config.cwd, config.filename, (err, dir) ->
        if err
          console.error(chalk.red("#{config.filename} not found in #{config.cwd} or parent directories"))
          process.exit(1)

        config.rootPath = dir

        cb()

    readConfig: ['locateConfigFile', (cb) ->
      fs.readFile(path.join(config.rootPath, config.filename), 'utf-8', cb)
    ]

    parseConfig: ['readConfig', (cb, results) ->
      try
        config.data = yaml.safeLoad(results.readConfig)
      catch err
        message = err.message.replace(/^JS-YAML: /, '')
        console.error(chalk.red("Error parsing #{config.filename}: #{message}"))
        process.exit(1)

      try
        config.normalise(config.data)
      catch err
        console.error(chalk.red("Error in #{config.filename}: #{err.message}"))
        process.exit(1)

      config.loaded = true
      cb()
    ]

    # Run callback
    cb
