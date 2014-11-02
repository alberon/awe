_      = require('lodash')
config = require('./config')
errTo  = require('errto')
fs     = require('fs')
output = require('./output')
path   = require('path')
S      = require('string')
yaml   = require('js-yaml')


module.exports = (file, bowerPath, cb) ->

  # Read YAML file
  await fs.readFile(file, 'utf8', errTo(cb, defer content))

  errorHandler = (message) ->
    # config.rootPath is not available in unit tests
    relFile = if config.rootPath then path.relative(config.rootPath, file) else file
    output.error(relFile, '(YAML import map)', message)

  # Parse YAML to JS
  try
    files = yaml.safeLoad(content)
  catch err
    if err instanceof yaml.YAMLException
      message = err.message.replace(/^JS-YAML: /, '')
      errorHandler("Error parsing YAML: #{message}")
      return cb(null, [])
    else
      return cb(err)

  # Normalise it
  files = normalise(files, path.dirname(file), bowerPath, errorHandler)

  # Run callback
  cb(null, files)


# This is exported for unit testing only
normalise = module.exports.normalise = (files, filePath, bowerPath, error) ->
  if files not instanceof Array
    error("Does not contain an array of files")
    return []

  normalisedFiles = []

  for value in files

    # String value is simply a relative path to a file
    if typeof value is 'string'
      normalisedFiles.push(path.resolve(filePath, value))

    # The only other type allowed is an object (bower: file.js)
    else if typeof value isnt 'object' || value == null
      error("Invalid import path: should be a string or object:\n#{JSON.stringify(value)}")

    else if 'bower' not of value
      error("Invalid import path: object doesn't have a 'bower' key:\n#{JSON.stringify(value)}")

    else if !bowerPath
      error("Invalid import path: 'bower: #{value.bower}': Bower is disabled")

    else
      normalisedFiles.push(path.resolve(bowerPath, value.bower))

  return normalisedFiles
