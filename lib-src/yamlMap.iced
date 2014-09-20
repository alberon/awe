_               = require('lodash')
errTo           = require('errto')
fs              = require('fs')
path            = require('path')
yaml            = require('js-yaml')
YamlImportError = require('./errors').YamlImportError


module.exports = (file, bowerPath, cb) ->

  # Read YAML file
  await fs.readFile(file, 'utf8', errTo(cb, defer content))

  # Parse YAML to JS
  try
    data = yaml.safeLoad(content)
  catch err
    return cb(err)

  # Normalise it
  try
    data = normalise(data, path.dirname(file), bowerPath)
  catch err
    return cb(err)

  # Run callback
  cb(null, data)


module.exports.normalise = normalise = (data, filePath, bowerPath) ->
  if data not instanceof Array
    data = [data]

  for value, key in data
    if typeof value is 'string'
      data[key] = path.resolve(filePath, value)
    else if typeof value isnt 'object' || value == null
      throw new YamlImportError("Invalid entry - should be a string or object:\n#{JSON.stringify(value)}")
    else if 'bower' not of value
      throw new YamlImportError("Invalid entry - object doesn't have a 'bower' key:\n#{JSON.stringify(value)}")
    else if !bowerPath
      throw new YamlImportError('Bower is disabled')
    else
      data[key] = path.join(bowerPath, value.bower)

  return data
