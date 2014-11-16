chalk  = require('chalk')
glob   = require('glob')
path   = require('path')
params = require('./params')
pkg    = require('../package.json')
spawn  = require('child_process').spawn

exports.run = (command, cb) ->

  b = chalk.bold
  u = chalk.underline
  bu = chalk.bold.underline

  # Commands with no arguments
  # TODO: Separate help pages for each with more detail about what they do...
  if command.args[0] in ['build', 'help', 'init', 'version', 'watch']

    console.log """
      #{b 'SYNOPSIS'}

         awe #{u command.args[0]}

      #{b 'SEE ALSO'}

         Documentation: #{u 'http://awe.alberon.co.uk/'}
    """

  # Display list of all commands
  else

    console.log """
      #{b 'SYNOPSIS'}

         awe [#{b '-h'}|#{b '--help'}] #{u 'command'} [#{u 'args'}]

      #{b 'GLOBAL COMMANDS'}

         #{u 'help'}        Display help
         #{u 'init'}        Create awe.yaml in the current directory
         #{u 'version'}     Display Awe version

      #{b 'PROJECT COMMANDS'}

         #{u 'build'} (#{u 'b'})   Compile assets
         #{u 'watch'} (#{u 'w'})   Watch for changes and automatically recompile assets

      #{b 'SEE ALSO'}

         Documentation: #{u 'http://awe.alberon.co.uk/'}
    """
