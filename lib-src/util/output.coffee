_     = require('lodash')
chalk = require('chalk')
S     = require('string')

actions =
  # Information
  watching:  chalk.bold.cyan('WATCHING...')
  building:  chalk.bold.cyan('BUILDING...')
  finished:  chalk.bold.cyan('FINISHED.')

  # Source files
  error:     chalk.bold.white.bgRed('Error')
  modified:  chalk.bold.green.inverse('Modified')
  warning:   chalk.yellow.inverse('Warning')

  # Target files
  compiled:  chalk.bold.yellow('Compiled')
  copied:    chalk.bold.green('Copied')
  created:   chalk.bold.red('Created')
  emptied:   chalk.bold.red('Emptied')
  generated: chalk.bold.yellow('Generated')
  symlink:   chalk.bold.magenta('Symlink')

# Set this to the length of the longest action text (to avoid having to
# calculate it every time)
maxLength = 9

output = (action, filename = '', notes = '', message = '') ->

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
    text += ' ' + chalk.gray(notes)

  # Detailed message
  message = S(message).trim().s
  if message
    text += "\n\n#{message}\n"

  # Output
  if action == 'error'
    console.error(text)
  else
    console.log(text)

# Create a shorthand method for each action
_(actions).forOwn (i, action) ->
  output[action] = (file, notes, message) ->
    output(action, file, notes, message)

# Exit after displaying an error message
output.error = (file, notes, message, code = 2) ->
  output('error', file, notes, message)
  process.exit(code) unless code == false

# Output a blank line
output.line = ->
  console.log('')

module.exports = output
