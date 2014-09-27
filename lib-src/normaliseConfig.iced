_           = require('lodash')
ConfigError = require('./errors').ConfigError


# Helpers
requireSetting = (setting, config, key, allowedTypes) ->
  if key of config
    checkSettingType(setting, config, key, allowedTypes)
  else
    throw new ConfigError("Missing required setting '#{key}' in #{setting}")

optionalSetting = (setting, config, key, defaultValue, allowedTypes) ->
  if key of config
    checkSettingType(setting, config, key, allowedTypes)
  else
    config[key] = defaultValue

typesToString = (types) ->
  if types.length > 1
    last       = types.pop()
    secondLast = types.pop()
    types.push("#{secondLast} or #{last}")
  types = types.join(', ')

checkSettingType = (setting, config, key, allowedTypes) ->
  # Skip if no valid types specified
  return if allowedTypes == null

  # Single types can be passed directly
  if typeof allowedTypes in ['string', 'boolean']
    allowedTypes = [allowedTypes]

  value = config[key]
  type = typeof value
  typesForError = []

  # Check each type
  for allowedType in allowedTypes
    switch allowedType

      # Types
      when 'string', 'boolean'
        return if type is allowedType
        typesForError.push('a ' + allowedType)

      # Specific values
      when true, false
        return if value is allowedType
        typesForError.push(allowedType)

      # This shouldn't happen!
      else
        throw new Error("BUG: Unknown type '#{allowedType} in checkSettingType()")

  # No valid types found
  typesForError = typesToString(typesForError)
  throw new ConfigError("Setting '#{setting}.#{key}' must be #{typesForError} (actual type is #{type})")

allowedSettings = (setting, config, keys) ->
  for own key, value of config
    if key not in keys
      throw new ConfigError("Unknown setting '#{key}' in #{setting}")


# This method is reponsible for validating and normalising the config data
module.exports = (config) ->
  type = typeof config

  if type in ['object', 'string'] && _.isEmpty(config)
    throw new ConfigError("File is empty")

  if type != 'object'
    throw new ConfigError("Root must be an object (actual type is #{type})")

  if 'assets' of config
    parseAssets('assets', config.assets)

  allowedSettings('root', config, ['assets'])


parseAssets = (setting, config) ->
  for own key, value of config

    # Validate the name
    if key.match(/[^a-zA-Z0-9]/)
      throw new ConfigError("Invalid group name '#{key}' in #{setting} (a-z, 0-9 only)")

    parseAssetGroup("#{setting}.#{key}", value)


parseAssetGroup = (setting, config) ->
  requireSetting(setting, config, 'src', 'string')
  requireSetting(setting, config, 'dest', 'string')

  optionalSetting(setting, config, 'autoprefixer', false, 'boolean')
  optionalSetting(setting, config, 'bower', 'bower_components/', ['string', false])
  optionalSetting(setting, config, 'sourcemaps', true, 'boolean')

  allowedSettings(setting, config, ['src', 'dest', 'autoprefixer', 'bower', 'sourcemaps'])
