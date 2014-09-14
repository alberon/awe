chalk  = require('chalk')
config = require('./config')
fs     = require('fs')
path   = require('path')


exports.run = ->

  src  = path.resolve(__dirname, '../templates/awe.yaml')
  dest = path.resolve(process.cwd(), config.filename)

  if fs.existsSync(dest)
    console.error(chalk.red("#{config.filename} already exists"))
    process.exit(1)

  data = fs.readFileSync(src)
  fs.writeFileSync(dest, data)

  console.log(chalk.green("Created #{config.filename}"))
