path = require('path')

# We don't always need to load coffee-script, but when we do it must be loaded
# before source-map-support, because it installs its own error handler which
# must be overridden. For simplicity, we'll always load it - otherwise we'd need
# some way of determining whether we'll need it or not.
require('coffee-script')
require('source-map-support').install(handleUncaughtExceptions: false)

# Configure Mustache
require('mu2').root = path.resolve(__dirname, '../templates')
