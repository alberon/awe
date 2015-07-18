_     = require('lodash')
chalk = require('chalk')
S     = require('string')


actions =
  # Information
  watching:          chalk.bold.cyan('WATCHING... ') + chalk.bold.black('Press Ctrl+C to quit')
  watchingWithInput: chalk.bold.cyan('WATCHING... ') + chalk.bold.black('Press ') + chalk.white('b') + chalk.bold.black(' to build, ') + chalk.white('q') + chalk.bold.black(' to quit')
  building:          chalk.bold.cyan('BUILDING...')
  finished:          chalk.bold.cyan('FINISHED.')

  # Source files
  modified:  chalk.bold.green.inverse('Modified')
  warning:   chalk.yellow.inverse('Warning')
  error:     chalk.bold.white.bgRed('Error')

  # Target files
  created:   chalk.bold.red('Created')
  emptied:   chalk.bold.red('Emptied')
  symlink:   chalk.bold.magenta('Symlink')
  copied:    chalk.bold.green('Copied')
  compiled:  chalk.bold.green('Compiled')
  generated: chalk.bold.yellow('Generated')

# Set this to the length of the longest action text (to avoid having to
# calculate it every time)
maxLength = 9

# Disable output?
quiet = false


output = (action, filename = '', notes = '', message = '') ->
  # Reset counters when building starts
  if action == 'building'
    output.resetCounters()

  # Count for unit tests
  output.counters[action] ||= 0
  output.counters[action]++

  # Hide output during unit tests
  return if quiet

  # Action
  text = actions[action]

  # Spaces
  if filename || notes
    text += S(' ').repeat(maxLength - chalk.stripColor(text).length + 2).s

  # Filename
  if filename
    if action == 'error'
      text += chalk.bold.red(filename)
    else if action == 'warning'
      text += chalk.yellow(filename)
    else
      text += chalk.bold(filename)

  # Notes
  if notes
    text += ' ' if filename
    text += chalk.gray(notes)

  # Display error/warning count when finished building
  if action == 'finished'
    if output.counters.error
      s = if output.counters.error == 1 then '' else 'S'
      text += '\n' + chalk.bold.white.bgRed(" ** #{output.counters.error} ERROR#{s}  ** ")
    if output.counters.warning
      s = if output.counters.warning == 1 then '' else 'S'
      text += '\n' + chalk.yellow.inverse(" ** #{output.counters.warning} WARNING#{s} ** ")

  # Detailed message
  message = S(message).trim().s
  if message
    text += "\n\n#{message}\n"

  # Output
  if action in ['error', 'warning']
    console.error(text)
  else
    console.log(text)


# Create a shorthand method for each action
_(actions).forOwn (i, action) ->
  output[action] = (file, notes, message) ->
    output(action, file, notes, message)


# Output a blank line
output.line = ->
  return if quiet
  console.log()


# Enable/disable output during unit tests
output.disable = ->
  quiet = true

output.enable = ->
  quiet = false


# Count messages for unit tests
output.counters = {}

output.resetCounters = ->
  output.counters = {}


module.exports = output
