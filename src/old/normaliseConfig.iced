_           = require('lodash')
ConfigError = require('./errors').ConfigError


# Helpers
requiredSetting = (setting, config, key, allowedTypes) ->
  if key of config
    checkSettingType(setting, config, key, allowedTypes)
  else
    throw new ConfigError("Missing required setting '#{key}' in #{setting}")


optionalSetting = (setting, config, key, allowedTypes, defaultValue) ->
  if key of config
    checkSettingType(setting, config, key, allowedTypes)
    return true
  else
    config[key] = defaultValue
    return false


typesToString = (types) ->
  if types.length > 1
    last       = types.pop()
    secondLast = types.pop()
    types.push("#{secondLast} or #{last}")
  types = types.join(', ')


settingName = (setting, key) ->
  if setting
    if key then "Setting '#{setting}.#{key}'" else "Setting '#{setting}'"
  else
    if key then "Setting '#{key}'" else 'Root'


checkSettingType = (setting, config, key, allowedTypes) ->
  # Skip if no valid types specified
  return if allowedTypes == null

  # Single types can be passed directly
  if !_.isArray(allowedTypes)
    allowedTypes = [allowedTypes]

  value = if key then config[key] else config

  type = typeof value
  if type is 'object' and _.isArray(value)
    type = 'array'

  typesForError = []

  # Check each type
  for allowedType in allowedTypes
    switch allowedType

      # Types
      when 'string', 'boolean'
        return if type is allowedType
        typesForError.push('a ' + allowedType)

      when 'array', 'object'
        return if type is allowedType
        typesForError.push('an ' + allowedType)

      # Specific values
      when true, false
        return if value is allowedType
        typesForError.push(allowedType)

      # This shouldn't happen!
      else
        throw new Error("BUG: Unknown type '#{allowedType} in checkSettingType()")

  # No valid types found
  typesForError = typesToString(typesForError)
  throw new ConfigError("#{settingName(setting, key)} must be #{typesForError} (actual type is #{type})")


allowedSettings = (setting, config, keys) ->
  for own key, value of config
    if key not in keys
      throw new ConfigError("Unknown setting '#{key}' in #{setting}")


# This method is reponsible for validating and normalising the config data
module.exports = (config) ->
  type = typeof config

  # Root
  if type in ['object', 'string'] && _.isEmpty(config)
    throw new ConfigError("File is empty")

  checkSettingType(null, config, null, 'object')

  # Setting groups
  allowedSettings(null, config, ['ASSETS'])

  if optionalSetting(null, config, 'ASSETS', ['object'])
    parseAssets('ASSETS', config.ASSETS)


parseAssets = (setting, config) ->
  for own key, value of config

    # Validate the name
    if key.match(/[^a-zA-Z0-9]/)
      throw new ConfigError("Invalid group name '#{key}' in #{setting} (a-z, 0-9 only)")

    # Validate the type
    checkSettingType(setting, config, key, 'object')

    parseAssetGroup("#{setting}.#{key}", value)


parseAssetGroup = (setting, config) ->
  allowedSettings(setting, config, ['src', 'dest', 'autoprefixer', 'bower'])

  requiredSetting(setting, config, 'src', 'string')
  requiredSetting(setting, config, 'dest', 'string')

  optionalSetting(setting, config, 'autoprefixer', 'boolean', false)
  optionalSetting(setting, config, 'bower', ['string', false], false)

  # Forced settings - may be made editable in the future, but for now they are
  # only used to speed up unit testing
  config.sourcemaps  = true
  config.warningfile = true
