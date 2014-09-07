_     = require('lodash')
chalk = require('chalk')
S     = require('string')

actions =
  compiled:  chalk.bold.yellow('Compiled')
  copied:    chalk.bold.green('Copied')
  created:   chalk.bold.red('Created')
  emptied:   chalk.bold.red('Emptied')
  generated: chalk.bold.yellow('Generated')
  error:     chalk.bold.white.bgRed('Error')
  symlink:   chalk.bold.magenta('Symlink')
  warning:   chalk.bold.yellow.inverse('Warning')

# Set this to the length of the longest action text (to avoid having to
# calculate it every time)
maxLength = 9

log = (action, file, notes = '', message = '') ->

  # Action
  text = actions[action]

  # Spaces
  text += S(' ').repeat(maxLength - chalk.stripColor(text).length + 2).s

  # Filename
  if action == 'error'
    text += chalk.bold.red(file)
  else if action == 'warning'
    text += chalk.bold.yellow(file)
  else
    text += chalk.bold(file)

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
  log[action] = (file, notes, message) ->
    log(action, file, notes, message)

# Exit after displaying an error message
log.error = (file, notes, message, code = 2) ->
  log('error', file, notes, message)
  process.exit(code) unless code == false

module.exports = log
