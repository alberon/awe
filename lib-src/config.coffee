async  = require('async')
findup = require('findup')
fs     = require('fs')
path   = require('path')
yaml   = require('js-yaml')

config = module.exports

config.cwd      = process.cwd() # For unit tests
config.data     = null
config.filename = 'awe.yaml'
config.loaded   = false
config.rootDir  = null

config.load = (cb) ->
  return cb() if config.loaded

  async.auto

    locateConfigFile: (cb) ->
      findup config.cwd, config.filename, (err, dir) ->
        if err
          console.error("#{config.filename} not found in #{config.cwd}")
          process.exit(1)

        config.rootDir = dir

        cb()

    readConfig: ['locateConfigFile', (cb) ->
      fs.readFile(path.join(config.rootDir, config.filename), 'utf-8', cb)
    ]

    parseConfig: ['readConfig', (cb, results) ->
      try
        config.data = yaml.safeLoad(results.readConfig)
      catch err
        return cb(err)
      config.loaded = true
      cb()
    ]

    # Run callback
    cb
