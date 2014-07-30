fs   = require('fs')
path = require('path')
pkg  = require('../package.json')

exports.run = ->

  version = pkg.version

  if fs.existsSync(path.join(__dirname, '../.git'))
    version += '-dev'

  console.log "Awe version #{version}"
