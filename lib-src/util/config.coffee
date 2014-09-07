async  = require('async')
findup = require('findup')
fs     = require('fs')
path   = require('path')
yaml   = require('js-yaml')

exports.filename = filename = 'awe.yaml'

exports.load = (cb) ->
  async.auto

    # Locate config file
    root: (cb) ->
      cwd = process.cwd()

      findup cwd, filename, (err, dir) ->
        if err
          console.error("#{filename} not found in #{cwd}")
          process.exit(1)

        cb(null, dir)

    # Read config file
    content: ['root', (cb, results) ->
      fs.readFile(path.join(results.root, filename), 'utf-8', cb)
    ]

    # Parse config
    config: ['content', (cb, results) ->
      try
        config = yaml.safeLoad(results.content)
      catch err
        return cb(err)
      cb(null, config)
    ]

    # Run callback
    (err, results) -> cb err,
      data: results.config
      root: results.root
