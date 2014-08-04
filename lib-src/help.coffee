chalk  = require('chalk')
glob   = require('glob')
path   = require('path')
params = require('./util/params')
pkg    = require('../package.json')
spawn  = require('child_process').spawn

exports.run = (command) ->

  console.log(chalk.bold('Usage:') + ' awe ' + chalk.underline('command') + ' [args]')
  console.log('')
  console.log(chalk.bold.underline('Global commands'))
  console.log('')
  console.log('  help      Display help')
  console.log('  init      Create awe.yaml in the current directory')
  console.log('  version   Display Awe version')
  console.log('')
  console.log(chalk.bold.underline('Project commands'))
  console.log('')
  console.log('  build     Compile assets')
  console.log('  watch     Watch for changes and automatically recompile assets')
  console.log('')
  console.log(chalk.bold.underline('See also'))
  console.log('')
  # TODO: Check if it was install from Git or npm - if Git, display the branch name or commit id?
  console.log('  Documentation: ' + chalk.underline('https://github.com/davejamesmiller/awe/blob/v' + pkg.version + '/README.md'))
