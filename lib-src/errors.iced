class exports.ConfigError extends Error
  constructor: (@message) ->
    Error.captureStackTrace(this, arguments.callee);


class exports.YamlImportError extends Error
  constructor: (@message) ->
    Error.captureStackTrace(this, arguments.callee);
