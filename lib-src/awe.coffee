chalk  = require('chalk')
params = require('./util/params')

try
  command = params.parse(process.argv[2...])
catch e
  console.error(chalk.red(e.message))
  process.exit(1)

require('./' + command.module).run(command)
