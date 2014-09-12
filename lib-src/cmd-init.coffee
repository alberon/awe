chalk = require('chalk')
fs    = require('fs')
path  = require('path')

exports.run = ->

  src = path.resolve(__dirname, '../templates/awe.yaml')
  dest = path.resolve(process.cwd(), 'awe.yaml')

  if fs.existsSync(dest)
    console.error(chalk.red('awe.yaml already exists'))
    process.exit(1)

  data = fs.readFileSync(src)
  fs.writeFileSync(dest, data)

  console.log(chalk.green('Created awe.yaml'))
