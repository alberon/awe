_      = require('lodash')
errTo  = require('errto')
fs     = require('fs')
output = require('./output')
path   = require('path')
S      = require('string')
yaml   = require('js-yaml')


module.exports = (file, srcPath, bowerPath, cb) ->

  # Read YAML file
  await fs.readFile(file, 'utf8', errTo(cb, defer content))

  errorHandler = (message) ->
    output.error(file, '(YAML import map)', message)

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
  files = normalise(files, path.dirname(file), srcPath, bowerPath, errorHandler)

  # Run callback
  cb(null, files)


# This is exported for unit testing only
normalise = module.exports.normalise = (files, filePath, srcPath, bowerPath, error) ->
  if files not instanceof Array
    files = [files]

  normalisedFiles = []

  for value in files

    # String value is simply a relative path to a file
    if typeof value is 'string'
      file = path.resolve(filePath, value)

      if S(file).startsWith(srcPath)
        normalisedFiles.push(file)
      else
        error("Invalid import path: '#{value}' resolves to '#{file}' which is outside the src directory '#{srcPath}' (skipped)")

    # The only other type allowed is an object (bower: file.js)
    else if typeof value isnt 'object' || value == null
      error("Invalid import path: should be a string or object:\n#{JSON.stringify(value)}")

    else if 'bower' not of value
      error("Invalid import path: object doesn't have a 'bower' key:\n#{JSON.stringify(value)}")

    else if !bowerPath
      error("Invalid import path: 'bower: #{value.bower}': Bower is disabled")

    else
      file = path.resolve(bowerPath, value.bower)

      if S(file).startsWith(bowerPath)
        normalisedFiles.push(file)
      else
        error("Invalid import path: 'bower: #{value.bower}' resolves to '#{file}' which is outside the Bower directory '#{bowerPath}' (skipped)")

  return normalisedFiles
