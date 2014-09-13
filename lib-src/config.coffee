async     = require('async')
findup    = require('findup')
fs        = require('fs')
normalise = require('./normaliseConfig')
path      = require('path')
yaml      = require('js-yaml')

config = module.exports

config.filename = 'awe.yaml'
config.cwd      = process.cwd() # For unit tests
config.loaded   = false
config.data     = null
config.rootPath = null

config.load = (cb) ->
  return cb() if config.loaded

  async.auto

    locateConfigFile: (cb) ->
      findup config.cwd, config.filename, (err, dir) ->
        if err
          console.error("#{config.filename} not found in #{config.cwd}")
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
        return cb(err)

      normalise(config.data)
      config.loaded = true
      cb()
    ]

    # Run callback
    cb
