fs   = require('fs')
path = require('path')
pkg  = require('../package.json')

exports.run = (command, cb) ->

  version = pkg.version

  await fs.exists(path.join(__dirname, '../.git'), defer exists)

  if exists
    version += '-dev'

  console.log "Awe version #{version}"
