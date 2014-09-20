chalk       = require('chalk')
ConfigError = require('./errors').ConfigError
errTo       = require('errto')
findup      = require('findup')
fs          = require('fs')
normalise   = require('./normaliseConfig')
path        = require('path')
yaml        = require('js-yaml')

config          = module.exports
config.filename = 'awe.yaml'
config.loaded   = false
config.data     = null
config.rootPath = null

# For unit tests
config.cwd       = process.cwd()
config.normalise = normalise


config.load = (cb) ->

  # Only load once
  return cb() if config.loaded

  # Find awe.yaml
  await findup(config.cwd, config.filename, defer(err, config.rootPath))

  if err
    console.error(chalk.red("#{config.filename} not found in #{config.cwd} or parent directories"))
    process.exit(1)

  # Read awe.yaml
  await fs.readFile(path.join(config.rootPath, config.filename), 'utf-8', errTo(cb, defer content))

  # Parse YAML data
  try
    config.data = yaml.safeLoad(content)
  catch err
    if err instanceof yaml.YAMLException
      message = err.message.replace(/^JS-YAML: /, '')
      console.error(chalk.red("Error parsing #{config.filename}: #{message}"))
      process.exit(1)
    else
      return cb(err)

  # Normalise & validate config data
  try
    config.normalise(config.data)
  catch err
    if err instanceof ConfigError
      console.error(chalk.red("Error in #{config.filename}: #{err.message}"))
      process.exit(1)
    else
      return cb(err)

  config.loaded = true

  # Run callback
  cb()
