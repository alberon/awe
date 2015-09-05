path = require('path')

# Prevent EMFILE error when opening a large number of files
require('graceful-fs').gracefulify(require('fs'))

# We don't always need to load coffee-script, but when we do it must be loaded
# before source-map-support, because it installs its own error handler which
# must be overridden. For simplicity, we'll always load it - otherwise we'd need
# some way of determining whether we'll need it or not.
require('coffee-script')
require('source-map-support').install(handleUncaughtExceptions: false)

# Display stack traces for unhandled async errors
require('trace')

# Exclude node internal calls from stack traces
require('clarify')

# Increase the stack trace limit (from 10)
Error.stackTraceLimit = Infinity;
