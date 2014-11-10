_ = require('lodash')


# These are the primary commands, mapping to the modules that implement them
exports.commands = commands =
  build:   'cmd-build'
  help:    'cmd-help'
  init:    'cmd-init'
  watch:   'cmd-watch'
  version: 'cmd-version'

# These are the official synonyms for the primary commands. The abbrev()
# function will add some additional shorthands for any unique prefixes.
exports.synonyms = synonyms =
  b: 'build'
  w: 'watch'

# Parse the command line arguments - determine any global parameters, the module
# to load and any remaining command parameters (unmodified). This is done,
# manually, not using a package, because we don't want to alter any command
# parameters that may need to be passed to an external program.
exports.parse = (args) ->
  command = {
    name:   ''
    module: ''
    args:   args
  }

  # This doesn't do much since it'll only ever loop once, but it's here for
  # future use when there are global parameters needed
  while args.length
    arg = args.shift()

    if synonym = synonyms[arg]
      arg = synonym

    if commands[arg]
      command.name   = arg
      command.module = commands[arg]

      # Special case for -h and --help command parameters (with no other
      # parameters), for consistency and to save each command implementing
      # this flag separately
      if _.isEqual(args, ['-h']) || _.isEqual(args, ['--help'])
        command.name   = 'help'
        command.module = commands['help']
        command.args   = [arg]

      return command

    # Global help flag
    else if arg == '-h' || arg == '--help'
      command.name   = 'help'
      command.module = commands['help']
      return command

    # Global version flag
    else if arg == '-v' || arg == '--version'
      command.name   = 'version'
      command.module = commands['version']
      return command

    # Unknown global parameter
    else if arg[0...1] == '-'
      throw new Error('Unknown global parameter: ' + arg)

    # Unknown command
    else
      throw new Error('Unknown command: ' + arg)

  # No command given
  command.name   = 'help'
  command.module = commands['help']
  return command
