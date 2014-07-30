_           = require('lodash')
async       = require('async')
chalk       = require('chalk')
coffee      = require('coffee-script')
css         = require('./css')
fs          = require('fs')
mkdirp      = require('mkdirp')
path        = require('path')
rmdir       = require('rimraf')
S           = require('string')
spawn       = require('child_process').spawn
tmp         = require('tmp')
UrlRewriter = require('./UrlRewriter')

tmp.setGracefulCleanup()

aweDir   = '.awe'
aweRoot  = path.resolve(__dirname, '../..')
bowerSrc = null
siteRoot = null

logActions =
  compiled:  chalk.bold.yellow('Compiled')
  copied:    chalk.bold.green('Copied')
  created:   chalk.bold.red('Created')
  emptied:   chalk.bold.red('Emptied')
  generated: chalk.bold.yellow('Generated')
  error:     chalk.bold.white.bgRed('Error')
  symlink:   chalk.bold.magenta('Symlink')
  warning:   chalk.bold.yellow.inverse('Warning')

log = (action, file, notes = '', before = '', after = '') ->
  actionText = logActions[action]
  actionLength = chalk.stripColor(actionText).length
  maxLength = 9 # Set to the length of the longest action text
  spaces = S(' ').repeat(maxLength - actionLength + 2).s

  if action == 'error'
    file = chalk.bold.red(file)
  else if action == 'warning'
    file = chalk.bold.yellow(file)
  else
    file = chalk.bold(file)

  if notes
    notes = ' ' + chalk.gray(notes)

  message = actionText + spaces + file + notes

  if action == 'error'
    console.error(before + message + after)
  else
    console.log(before + message + after)

warning = (file, message) ->
  message = S(message).trim().s
  log('warning', file, null, '', "\n\n#{message}\n")

error = (file, message, code = 2) ->
  message = S(message).trim().s
  log('error', file, null, '', "\n\n#{message}\n")
  process.exit(code)

exports.prepare = (root, cb) ->
  siteRoot = root
  process.chdir(siteRoot) # TODO Shouldn't need to do this...

  # Create .awe/ directory
  fs.mkdir path.join(root, aweDir), (err) ->
    return cb(err) if err and err.code != 'EEXIST'

    # Create awe/.gitignore
    gitignore = path.join(root, aweDir, '.gitignore')
    fs.writeFile(gitignore, '# Automatically generated by Awe - ignore all files\n*\n', cb)

exports.compileGroup = (group, cb) ->
  # Normalise paths
  group.src = group.src.replace(/\/*$/, '')
  group.dest = group.dest.replace(/\/*$/, '')

  async.auto

    # Need to know if the destination already exists for the log message
    destExists: (cb) ->
      fs.exists(group.dest, (exists) -> cb(null, exists))

    # Delete the destination
    deleteDest: ['destExists', (cb, results) ->
      rmdir(group.dest, cb)
    ]

    # (Re-)create the destination
    createDest: ['deleteDest', (cb, results) ->
      mkdirp(group.dest, cb)
    ]

    destCreated: ['createDest', (cb, results) ->
      if results.destExists
        log('emptied', group.dest + '/')
      else
        log('created', group.dest + '/')
      cb()
    ]

    # Create a symlink to the source directory
    symlinkSrc: ['destCreated', (cb, results) ->
      group.srcLink = path.join(group.dest, '_src')
      target = path.relative(path.dirname(group.srcLink), group.src)
      fs.symlink(target, group.srcLink, cb)
    ]

    srcSymlinkCreated: ['symlinkSrc', (cb) ->
      log('symlink', group.srcLink + '/')
      cb()
    ]

    # Create a symlink to the bower_components directory
    symlinkBower: ['destCreated', (cb) ->
      if group.bower
        group.bowerPath = path.join(group.dest, '_bower')
        bowerSrc = path.join(siteRoot, 'bower_components')
        target = path.relative(path.dirname(group.bowerPath), bowerSrc)
        fs.symlink(target, group.bowerPath, cb)
      else
        cb()
    ]

    bowerSymlinkCreated: ['symlinkBower', (cb) ->
      if group.bower
        log('symlink', group.bowerPath + '/')
      cb()
    ]

    # Compile the directory
    compile: ['srcSymlinkCreated', 'bowerSymlinkCreated', (cb) ->
      compileDirectory(group.src, group.dest, group, cb)
    ]

    # Run the callback
    cb

writeFile = (dest, {content, count}, action, cb) ->
  fs.writeFile dest, content, (err) ->
    return cb(err) if err
    if action
      log(action, dest, "(#{count} files)" if count > 1)
    cb()

compileFileOrDirectory = (src, dest, group, cb) ->
  fs.lstat src, (err, stat) ->
    return cb(err) if err

    if stat.isDirectory()
      compileDirectory(src, dest, group, cb)
    else
      compileFile(src, dest, group, cb)

compileDirectory = (src, dest, group, cb) ->
  if src[-4...].toLowerCase() == '.css'
    compileCssDirectory src, dest, group, (err, data) ->
      return cb(err) if err
      writeFile(dest, data, 'compiled', cb)

  else if src[-3...].toLowerCase() == '.js'
    compileJsDirectory src, dest, group, (err, data) ->
      return cb(err) if err
      writeFile(dest, data, 'compiled', cb)

  else
    compileRegularDirectory(src, dest, group, cb)

compileRegularDirectory = (src, dest, group, cb) ->
  async.auto

    # Create the destination directory
    mkdir: (cb) ->
      mkdirp(dest, cb)

    # Get a list of files in the source directory
    files: (cb) ->
      fs.readdir(src, cb)

    # Iterate through the files
    compile: ['mkdir', 'files', (cb, results) ->
      async.each(results.files, (file, cb) ->
        if file[0...1] == '_'
          return cb()

        srcFile = path.join(src, file)
        destFile = path.join(dest, file)

        compileFileOrDirectory(srcFile, destFile, group, cb)
      , cb)
    ]

    # Run the callback
    cb

compileCoffeeScript = (src, cb) ->
  fs.readFile src, encoding: 'utf8', (err, coffeescript) ->
    return cb(err) if err
    # TODO: sourceMap
    javascript = coffee.compile(coffeescript)
    cb(null, javascript)

compileSass = (src, group, cb) ->
  pathFromRoot = path.relative(group.src, path.dirname(src)) || '.'
  pathToRoot = path.relative(path.dirname(src), group.src) || '.'

  async.auto

    # Create a temp directory for the output
    tmpDir: (cb) ->
      tmp.dir(unsafeCleanup: true, cb)

    # Create a config file for Compass
    # (Compass doesn't let us specify all options using the CLI, so we have to
    # generate a config file instead. We could use `sass --compass` instead for
    # some of them, but that doesn't support all the options either.)
    configFile: (cb) ->
      tmp.file (err, filename, fd) ->
        cb(err, {filename, fd})

    writeConfig: ['configFile', (cb, results) ->
      config = """
        project_path = '#{siteRoot}'
        cache_path   = '#{path.join(aweDir, 'sass-cache')}'
        output_style = :expanded

        # Input files
        sass_path   = '#{group.src}'
        images_path = '#{group.src}/img'
        fonts_path  = '#{group.src}/fonts'

        # Output to a temp directory so we can catch any generated files too
        css_path              = '#{results.tmpDir}'
        generated_images_path = '#{results.tmpDir}/_generated'
        javascripts_path      = '#{results.tmpDir}/_generated' # Rarely used but might as well

        # Output a placeholder for URLs - we will rewrite them into relative paths later
        # (Can't use 'relative_assets' because it generates paths like '../../../tmp/tmp-123/img')
        http_path                  = '/AWEDESTROOTPATH'
        http_stylesheets_path      = '/AWEDESTROOTPATH'
        http_images_path           = '/AWEDESTROOTPATH/img'
        http_fonts_path            = '/AWEDESTROOTPATH/fonts'
        http_generated_images_path = '/AWEDESTROOTPATH/_generated'
        http_javascripts_path      = '/AWEDESTROOTPATH/_generated'

        # Disable cache busting URLs (e.g. sample.gif?123456) - we'll handle that too
        asset_cache_buster :none
      """

      fs.write(results.configFile.fd, new Buffer(config), 0, config.length, null, cb)
    ]

    closeConfig: ['writeConfig', (cb, results) ->
      fs.close(results.configFile.fd, cb)
    ]

    # Compile the file using Compass
    compile: ['closeConfig', (cb, results) ->
      cmd = path.join(aweRoot, 'ruby_bundle', 'bin', 'compass')
      args = ['compile', '--config', results.configFile.filename, src]

      output = ''
      bundle = spawn(cmd, args)
      bundle.stdout.on 'data', (data) -> output += data
      bundle.stderr.on 'data', (data) -> output += data
      bundle.on 'close', (code) ->
        if code == 0
          cb()
        else
          output = output.replace(/\n?\s*Use --trace for backtrace./, '')
          message = chalk.bold.red("SASS/COMPASS ERROR") + chalk.bold.black(" (#{code})") + "\n#{output}"
          error(src, message)
          cb('Sass compile failed')
    ]

    # Copy any extra files that were generated
    copyGeneratedFiles: ['compile', (cb, results) ->
      copyGeneratedDirectory(path.join(results.tmpDir, '_generated'), path.join(group.dest, '_generated'), group, cb)
    ]

    # Get the content from the CSS file
    sass: ['compile', (cb, results) ->
      outputFile = path.join(results.tmpDir, pathFromRoot, path.basename(src).replace(/\.scss$/, '.css'))
      fs.readFile(outputFile, encoding: 'utf8', cb)
    ]

    sassReplaced: ['sass', (cb, results) ->
      # Remove the comments showing the source lines until I can fix them
      # TODO: Rewrite the paths instead of removing them
      content = results.sass.replace(/\/\* line .*? \*\/\n/g, '')
      cb(null, content)
    ]

    # Run the callback
    (err, results) ->
      cb(err, results.sassReplaced)

copyGeneratedDirectory = (src, dest, group, cb) ->
  fs.readdir src, (err, files) ->
    if err && err.code == 'ENOENT'
      # src directory doesn't exist
      return cb()

    return cb(err) if err

    mkdirp dest, (err) ->
      return cb(err) if err

      copy = (file, cb) ->
        if file[0...1] == '_'
          return cb()

        srcFile = path.join(src, file)
        srcStat = fs.lstatSync(srcFile)
        destFile = path.join(dest, file)

        # Recurse into directory
        if srcStat.isDirectory()
          copyGeneratedDirectory(srcFile, destFile, group, cb)

        # Copy file
        else
          fs.readFile srcFile, (err, content) ->
            return cb(err) if err
            writeFile(destFile, {content}, 'generated', cb)

      async.each(files, copy, cb)

compileFile = (src, dest, group, cb) ->

  # Compile CoffeeScript
  if src[-7...].toLowerCase() == '.coffee'
    dest = dest[...-7] + '.js'
    compileCoffeeScript src, (err, content) ->
      return cb(err) if err
      writeFile(dest, {content}, 'compiled', cb)

  # Compile Sass
  else if src[-5...].toLowerCase() == '.scss'
    dest = dest[...-5] + '.css'
    compileSass src, group, (err, content) ->
      return cb(err) if err
      content = rewriteCss(content, src, dest, group)
      writeFile(dest, {content}, 'compiled', cb)

  # Copy CSS and replace URLs
  else if src[-4...].toLowerCase() == '.css'
    fs.readFile src, encoding: 'utf8', (err, content) ->
      return cb(err) if err
      content = rewriteCss(content, src, dest, group)
      writeFile(dest, {content}, 'copied', cb)

  # Copy other files
  else
    fs.readFile src, (err, content) ->
      return cb(err) if err
      writeFile(dest, {content}, 'copied', cb)

rewriteCss = (content, srcFile, destFile, group) ->
  rewriter = new UrlRewriter
    root:      siteRoot
    srcDir:    group.src
    srcFile:   srcFile
    destDir:   group.dest
    destFile:  destFile
    bowerSrc:  bowerSrc
    bowerDest: group.bowerPath

  css.rewriteUrls content, (url) ->
    if S(url).startsWith('/AWEDESTROOTPATH/')
      return path.join(path.relative(path.dirname(srcFile), group.src), url[17...])

    try
      rewriter.rewrite(url)
    catch e
      warning(srcFile, e.message)
      return url

compileCssDirectory = (src, dest, group, cb) ->
  fs.readdir src, (err, files) ->
    return cb(err) if err

    count = 0

    compile = (file, cb) ->
      if file[0...1] == '_'
        return cb()

      srcFile = path.join(src, file)
      srcStat = fs.lstatSync(srcFile)

      # Recurse into directory
      if srcStat.isDirectory()
        compileCssDirectory srcFile, dest, group, (err, data) ->
          count += data.count
          cb(null, data.content)

      # Compile Sass
      else if srcFile[-5...].toLowerCase() == '.scss'
        count++
        compileSass srcFile, group, (err, content) ->
          return cb(err) if err
          content = rewriteCss(content, srcFile, dest, group)
          cb(null, content)

      # Other CSS file
      else
        count++
        fs.readFile srcFile, encoding: 'utf8', (err, content) ->
          return cb(err) if err
          content = rewriteCss(content, srcFile, dest, group)
          cb(null, content)

    combine = (err, content) ->
      return cb(err) if err

      content = _.filter(content).join('\n')

      cb(null, {content, count})

    async.map(files, compile, combine)

compileJsDirectory = (src, dest, group, cb) ->
  fs.readdir src, (err, files) ->
    return cb(err) if err

    count = 0

    compile = (file, cb) ->
      if file[0...1] == '_'
        return cb()

      srcFile = path.join(src, file)
      srcStat = fs.lstatSync(srcFile)

      # Recurse into directory
      if srcStat.isDirectory()
        compileJsDirectory srcFile, dest, group, (err, data) ->
          count += data.count
          cb(null, data.content)

      # Compile CoffeeScript
      else if srcFile[-7...].toLowerCase() == '.coffee'
        count++
        compileCoffeeScript(srcFile, cb)

      # Other file
      else
        count++
        fs.readFile(srcFile, encoding: 'utf8', cb)

    combine = (err, content) ->
      return cb(err) if err

      content = _.filter(content).join('\n')

      cb(null, {content, count})

    async.map(files, compile, combine)
