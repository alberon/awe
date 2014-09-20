_     = require('lodash')
errTo = require('errto')
fs    = require('fs')
path  = require('path')
yaml  = require('js-yaml')


module.exports = (file, bowerPath, cb) ->

  filePath = path.dirname(file)

  # Read YAML file
  await fs.readFile(file, 'utf8', errTo(cb, defer content))

  # Parse YAML to JS
  try
    data = yaml.safeLoad(content)
  catch err
    return cb(err)

  # Normalise it
  if data not instanceof Array
    data = [data]

  for key, value of data
    if bowerPath && typeof value is 'object'
      data[key] = path.join(bowerPath, value.bower)
    else
      data[key] = path.resolve(filePath, value)

  # Run callback
  cb(null, data)
