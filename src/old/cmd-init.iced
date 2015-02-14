chalk  = require('chalk')
config = require('./config')
errTo  = require('errto')
fs     = require('fs')
path   = require('path')


exports.run = (command, cb) ->

  src  = path.resolve(__dirname, '../templates/awe.yaml')
  dest = path.resolve(process.cwd(), config.filename)

  await fs.exists(dest, defer exists)

  if exists
    console.error(chalk.red("#{config.filename} already exists"))
    process.exit(1)

  await fs.readFile(src, errTo(cb, defer(content)))
  await fs.writeFile(dest, content, errTo(cb, defer()))

  console.log(chalk.green("Created #{config.filename}"))
