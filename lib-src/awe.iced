# Change process title from 'node' to 'awe'
process.title = process.argv[1...].join(' ')

# Some basic setup
require('./common')

# Run the appropriate command
chalk  = require('chalk')
params = require('./params')

try
  command = params.parse(process.argv[2...])
catch e
  console.error(chalk.red(e.message))
  process.exit(1)

require('./' + command.module).run command, (err) ->
  # If an asynchronous error reaches this far, something is wrong
  throw err if err
