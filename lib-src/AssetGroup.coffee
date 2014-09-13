_            = require('lodash')
async        = require('async')
autoprefixer = require('autoprefixer-core')
cacheDir     = require('./cacheDir')
chalk        = require('chalk')
coffee       = require('coffee-script')
config       = require('./config')
css          = require('./css')
fs           = require('fs')
mkdirp       = require('mkdirp')
output       = require('./output')
path         = require('path')
readdir      = require('readdir')
rmdir        = require('rimraf')
S            = require('string')
spawn        = require('child_process').spawn
tmp          = require('tmp')
UrlRewriter  = require('./UrlRewriter')

tmp.setGracefulCleanup()


class AssetGroup

  constructor: (groupConfig) ->
    @autoprefixer = groupConfig.autoprefixer
    @bower        = groupConfig.bower

    # Normalise paths
    @srcPath  = groupConfig.src.replace(/\/*$/, '')
    @destPath = groupConfig.dest.replace(/\/*$/, '')

    # Generated paths
    @srcLink = path.join(@destPath, '_src')

    if @bower
      @bowerLink = path.join(@destPath, '_bower')
      @bowerSrc  = path.join(config.rootPath, @bower)
    else
      @bowerLink = null
      @bowerSrc  = null


  build: (cb) =>
    async.auto

      # Need to know if the destination already exists for the output message
      destExists: (cb) =>
        fs.exists(@destPath, (exists) => cb(null, exists))

      # Delete the destination
      deleteDest: ['destExists', (cb, results) =>
        rmdir(@destPath, cb)
      ]

      # (Re-)create the destination
      createDest: ['deleteDest', (cb, results) =>
        mkdirp(@destPath, cb)
      ]

      destCreated: ['createDest', (cb, results) =>
        if results.destExists
          output.emptied(@destPath + '/')
        else
          output.created(@destPath + '/')
        cb()
      ]

      # Create a symlink to the source directory
      symlinkSrc: ['destCreated', (cb, results) =>
        target = path.relative(path.dirname(@srcLink), @srcPath)
        fs.symlink(target, @srcLink, cb)
      ]

      srcSymlinkCreated: ['symlinkSrc', (cb) =>
        output.symlink(@srcLink + '/')
        cb()
      ]

      # Create a symlink to the bower_components directory
      symlinkBower: ['destCreated', (cb) =>
        if @bower
          target = path.relative(path.dirname(@bowerLink), @bowerSrc)
          fs.symlink(target, @bowerLink, cb)
        else
          cb()
      ]

      bowerSymlinkCreated: ['symlinkBower', (cb) =>
        if @bower
          output.symlink(@bowerLink + '/')
        cb()
      ]

      # Create cache directory
      prepareCache: cacheDir.prepare

      # Compile the directory
      compile: ['srcSymlinkCreated', 'bowerSymlinkCreated', 'prepareCache', (cb) =>
        @_compileRegularDirectory(@srcPath, @destPath, cb)
      ]

      # Run the callback
      cb


  _writeFile: (dest, {content, count}, action, cb) =>
    fs.writeFile dest, content, (err) =>
      return cb(err) if err
      if action
        output(action, dest, "(#{count} files)" if count > 1)
      cb()


  _compileDirectory: (src, dest, cb) =>
    if src[-4...].toLowerCase() == '.css'
      @_compileCssDirectory src, dest, (err, data) =>
        return cb(err) if err
        @_writeFile(dest, data, 'compiled', cb)

    else if src[-3...].toLowerCase() == '.js'
      @_compileJsDirectory src, dest, (err, data) =>
        return cb(err) if err
        @_writeFile(dest, data, 'compiled', cb)

    else
      @_compileRegularDirectory(src, dest, cb)


  _compileRegularDirectory: (src, dest, cb) =>
    async.auto

      # Create the destination directory
      mkdir: (cb) =>
        mkdirp(dest, cb)

      # Get a list of files in the source directory
      files: (cb) =>
        readdir.read(src, null, readdir.CASELESS_SORT + readdir.INCLUDE_DIRECTORIES + readdir.NON_RECURSIVE, cb)

      # Iterate through the files
      compile: ['mkdir', 'files', (cb, results) =>
        async.each(results.files, (file, cb) =>
          if file[0...1] == '_'
            return cb()

          srcFile = path.join(src, file)
          destFile = path.join(dest, file)

          if file[-1..] == '/'
            @_compileDirectory(srcFile[...-1], destFile[...-1], cb)
          else
            @_compileFile(srcFile, destFile, cb)
        , cb)
      ]

      # Run the callback
      cb


  _compileCoffeeScript: (src, cb) =>
    fs.readFile src, encoding: 'utf8', (err, coffeescript) =>
      return cb(err) if err
      # TODO: sourceMap
      javascript = coffee.compile(coffeescript)
      cb(null, javascript)


  _compileSass: (src, cb) =>
    async.auto

      # Create a temp directory for the output
      tmpDir: (cb) =>
        tmp.dir(unsafeCleanup: true, cb)

      # Create a config file for Compass
      # (Compass doesn't let us specify all options using the CLI, so we have to
      # generate a config file instead. We could use `sass --compass` instead for
      # some of them, but that doesn't support all the options either.)
      configFile: (cb) =>
        tmp.file (err, filename, fd) =>
          cb(err, filename: filename, fd: fd)

      writeConfig: ['configFile', (cb, results) =>
        compassConfig = """
          project_path = '#{config.rootPath}'
          cache_path   = '#{path.join(cacheDir.path, 'sass-cache')}'
          output_style = :expanded

          # Input files
          sass_path        = '#{@srcPath}'
          images_path      = '#{@srcPath}/img'
          fonts_path       = '#{@srcPath}/fonts'
          sprite_load_path << '#{@srcPath}/_sprites'

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

        fs.write(results.configFile.fd, new Buffer(compassConfig), 0, compassConfig.length, null, cb)
      ]

      closeConfig: ['writeConfig', (cb, results) =>
        fs.close(results.configFile.fd, cb)
      ]

      # Compile the file using Compass
      compile: ['closeConfig', (cb, results) =>
        cmd = path.resolve(__dirname, '..', 'ruby_bundle', 'bin', 'compass')
        args = ['compile', '--config', results.configFile.filename, src]

        result = ''
        bundle = spawn(cmd, args)
        bundle.stdout.on 'data', (data) => result += data
        bundle.stderr.on 'data', (data) => result += data
        bundle.on 'close', (code) =>
          if code == 0
            cb()
          else
            result = result.replace(/\n?\s*Use --trace for backtrace./, '')
            message = chalk.bold.red("SASS/COMPASS ERROR") + chalk.bold.black(" (#{code})") + "\n#{result}"
            output.error(src, 'Sass', message)
            cb('Sass compile failed')
      ]

      # Copy any extra files that were generated
      copyGeneratedFiles: ['compile', (cb, results) =>
        @_copyGeneratedDirectory(path.join(results.tmpDir, '_generated'), path.join(@destPath, '_generated'), cb)
      ]

      # Get the content from the CSS file
      sass: ['compile', (cb, results) =>
        pathFromRoot = path.relative(@srcPath, path.dirname(src)) || '.'
        outputFile = path.join(results.tmpDir, pathFromRoot, path.basename(src).replace(/\.scss$/, '.css'))
        fs.readFile(outputFile, encoding: 'utf8', cb)
      ]

      sassReplaced: ['sass', (cb, results) =>
        # Remove the comments showing the source lines until I can fix them
        # TODO: Rewrite the paths instead of removing them
        content = results.sass.replace(/\/\* line .*? \*\/\n/g, '')
        cb(null, content)
      ]

      # Run the callback
      (err, results) =>
        cb(err, results.sassReplaced)


  _copyGeneratedFileOrDirectory: (src, dest, file, cb) =>
    if file[0...1] == '_'
      return cb()

    srcFile = path.join(src, file)
    destFile = path.join(dest, file)

    fs.lstat srcFile, (err, stat) =>
      return cb(err) if err

      if stat.isDirectory()
        @_copyGeneratedDirectory(srcFile, destFile, cb)
      else
        @_copyGeneratedFile(srcFile, destFile, cb)


  _copyGeneratedFile: (src, dest, cb) =>
    fs.readFile src, (err, content) =>
      return cb(err) if err
      @_writeFile(dest, content: content, 'generated', cb)


  _copyGeneratedDirectory: (src, dest, cb) =>
    async.auto

      # Get a list of files
      fileList: (cb) =>
        fs.readdir(src, cb)

      # Create destination directory
      # Depends on 'fileList' to ensure the source directory exists first
      mkdir: ['fileList', (cb) =>
        mkdirp(dest, cb)
      ]

      # Copy the files
      copyFiles: ['fileList', 'mkdir', (cb, results) =>
        async.each(results.fileList, _.partial(@_copyGeneratedFileOrDirectory, src, dest), cb)
      ]

      # Run the callback
      (err, results) =>
        # Ignore directory not found error
        if err && err.code == 'ENOENT'
          err = null
        cb(err)


  _compileFile: (src, dest, cb) =>

    # Compile CoffeeScript
    if src[-7...].toLowerCase() == '.coffee'
      dest = dest[...-7] + '.js'
      @_compileCoffeeScript src, (err, content) =>
        return cb(err) if err
        @_writeFile(dest, content: content, 'compiled', cb)

    # Compile Sass
    else if src[-5...].toLowerCase() == '.scss'
      dest = dest[...-5] + '.css'
      @_compileSass src, (err, content) =>
        return cb(err) if err
        content = @_rewriteCss(content, src, dest)
        @_writeFile(dest, content: content, 'compiled', cb)

    # Copy CSS and replace URLs
    else if src[-4...].toLowerCase() == '.css'
      fs.readFile src, encoding: 'utf8', (err, content) =>
        return cb(err) if err
        content = @_rewriteCss(content, src, dest)
        @_writeFile(dest, content: content, 'copied', cb)

    # Copy other files
    else
      fs.readFile src, (err, content) =>
        return cb(err) if err
        @_writeFile(dest, content: content, 'copied', cb)


  _rewriteCss: (content, srcFile, destFile) =>
    urlRewriter = new UrlRewriter
      root:      config.rootPath
      srcDir:    @srcPath
      srcFile:   srcFile
      destDir:   @destPath
      destFile:  destFile
      bowerSrc:  @bowerSrc
      bowerDest: @bowerLink

    # URL rewriting
    content = css.rewriteUrls content, (url) =>
      if S(url).startsWith('/AWEDESTROOTPATH/')
        return path.join(path.relative(path.dirname(srcFile), @srcPath), url[17...])

      try
        urlRewriter.rewrite(url)
      catch e
        output.warning(srcFile, '(URL rewriter)', e.message)
        return url

    # Autoprefixer
    if @autoprefixer
      content = autoprefixer.process(content).css

    return content


  _compileCssDirectory: (src, dest, cb) =>
    readdir.read src, null, readdir.CASELESS_SORT, (err, files) =>
      return cb(err) if err

      count = 0

      compile = (file, cb) =>
        if file[0...1] == '_'
          return cb()

        srcFile = path.join(src, file)

        # Compile Sass
        if srcFile[-5...].toLowerCase() == '.scss'
          count++
          @_compileSass srcFile, (err, content) =>
            return cb(err) if err
            content = @_rewriteCss(content, srcFile, dest)
            cb(null, content)

        # Other CSS file
        else
          count++
          fs.readFile srcFile, encoding: 'utf8', (err, content) =>
            return cb(err) if err
            content = @_rewriteCss(content, srcFile, dest)
            cb(null, content)

      combine = (err, content) =>
        return cb(err) if err

        content = _.filter(content).join('\n')

        cb(null, content: content, count: count)

      async.map(files, compile, combine)


  _compileJsDirectory: (src, dest, cb) =>
    readdir.read src, null, readdir.CASELESS_SORT, (err, files) =>
      return cb(err) if err

      count = 0

      compile = (file, cb) =>
        if file[0...1] == '_'
          return cb()

        srcFile = path.join(src, file)

        # Compile CoffeeScript
        if srcFile[-7...].toLowerCase() == '.coffee'
          count++
          @_compileCoffeeScript(srcFile, cb)

        # Other file
        else
          count++
          fs.readFile(srcFile, encoding: 'utf8', cb)

      combine = (err, content) =>
        return cb(err) if err

        content = _.filter(content).join('\n')

        cb(null, content: content, count: count)

      async.map(files, compile, combine)


module.exports = AssetGroup
