_ = require('lodash')


# Helpers
requireSetting = (setting, config, key) ->
  if key not of config
    throw new ConfigError("Missing required setting '#{key}' in #{setting}")

optionalSetting = (settings, config, key, defaultValue = null) ->
  if key not of config
    config[key] = defaultValue

stringSetting = (setting, config, key) ->
  if key of config && (type = typeof config[key]) != 'string'
    throw new ConfigError("Setting '#{key}' must be a string in #{setting} (type is #{type})")

requireStringSetting = (setting, config, key) ->
  requireSetting(setting, config, key)
  stringSetting(setting, config, key)

allowedSettings = (setting, config, keys) ->
  for own key, value of config
    if key not in keys
      throw new ConfigError("Unknown setting '#{key}' in #{setting}")


# This method is reponsible for validating and normalising the config data
module.exports = (config) ->
  type = typeof config

  if type in ['object', 'string'] && _.isEmpty(config)
    throw new ConfigError("Config file is empty")

  if type != 'object'
    throw new ConfigError("Config root must be an object (type is #{type})")

  if 'assets' of config
    parseAssets('assets', config.assets)

  allowedSettings('(root)', config, ['assets'])


parseAssets = (setting, config) ->
  for own key, value of config

    # Validate the name
    if key.match(/[^a-zA-Z0-9]/)
      throw new ConfigError("Invalid group name '#{key}' in #{setting} (a-z, 0-9 only)")

    parseAssetGroup("#{setting}.#{key}", value)


parseAssetGroup = (setting, config) ->
  requireStringSetting(setting, config, 'src')
  requireStringSetting(setting, config, 'dest')

  optionalSetting(setting, config, 'autoprefixer', false)
  optionalSetting(setting, config, 'bower', true)

  allowedSettings(setting, config, ['src', 'dest', 'bower', 'autoprefixer'])


# Custom error class so we can catch them and display an error message
class ConfigError extends Error
  constructor: (@message) -> super

module.exports.ConfigError = ConfigError


