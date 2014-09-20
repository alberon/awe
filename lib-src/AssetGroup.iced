_            = require('lodash')
async        = require('async')
autoprefixer = require('autoprefixer-core')
cacheDir     = require('./cacheDir')
chalk        = require('chalk')
coffee       = require('coffee-script')
config       = require('./config')
css          = require('./css')
errTo        = require('errto')
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
yamlMap      = require('./yamlMap')

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
    # Need to know if the destination already exists for the output message
    await fs.exists(@destPath, defer(destExists))

    # Delete the destination
    await rmdir(@destPath, errTo(cb, defer()))

    # (Re-)create the destination
    await mkdirp(@destPath, errTo(cb, defer()))

    if destExists
      output.emptied(@destPath + '/')
    else
      output.created(@destPath + '/')

    await
      # Create a symlink to the source directory
      target = path.relative(path.dirname(@srcLink), @srcPath)
      fs.symlink(target, @srcLink, errTo(cb, defer()))

      output.symlink(@srcLink + '/')

      # Create a symlink to the bower_components directory
      if @bower
        target = path.relative(path.dirname(@bowerLink), @bowerSrc)
        fs.symlink(target, @bowerLink, errTo(cb, defer()))
        output.symlink(@bowerLink + '/')

      # Create cache directory
      cacheDir.prepare(errTo(cb, defer()))

    # Compile the directory
    @_compileRegularDirectory(@srcPath, @destPath, cb)


  _writeFile: (dest, {content, count}, action, cb) =>
    await fs.writeFile(dest, content, errTo(cb, defer()))

    if action
      output(action, dest, "(#{count} files)" if count > 1)

    cb()


  _compileDirectory: (src, dest, cb) =>
    if src[-4...].toLowerCase() == '.css'
      await @_compileCssDirectory(src, dest, errTo(cb, defer data))
      @_writeFile(dest, data, 'compiled', cb)

    else if src[-3...].toLowerCase() == '.js'
      await @_compileJsDirectory(src, dest, errTo(cb, defer data))
      @_writeFile(dest, data, 'compiled', cb)

    else
      @_compileRegularDirectory(src, dest, cb)


  _compileRegularDirectory: (src, dest, cb) =>

    await
      # Create the destination directory
      mkdirp(dest, defer())

      # Get a list of files in the source directory
      readdir.read(
        src,
        null,
        readdir.CASELESS_SORT + readdir.INCLUDE_DIRECTORIES + readdir.NON_RECURSIVE,
        errTo(cb, defer files)
      )

    # Compile each of the files/directories in parallel
    await
      for file in files
        continue if file[0...1] == '_'

        srcFile = path.join(src, file)
        destFile = path.join(dest, file)

        if file[-1..] == '/'
          @_compileDirectory(srcFile[...-1], destFile[...-1], errTo(cb, defer()))
        else
          @_compileFile(srcFile, destFile, errTo(cb, defer()))

    # Run the callback
    cb()


  _compileCoffeeScript: (src, cb) =>
    await fs.readFile(src, 'utf8', errTo(cb, defer coffeescript))
    # TODO: sourceMap
    javascript = coffee.compile(coffeescript)
    cb(null, javascript)


  _compileSass: (src, cb) =>

    # Create a temp directory for the output
    await tmp.dir(unsafeCleanup: true, errTo(cb, defer tmpDir))

    # Create a config file for Compass
    # (Compass doesn't let us specify all options using the CLI, so we have to
    # generate a config file instead. We could use `sass --compass` instead for
    # some of them, but that doesn't support all the options either.)
    await tmp.file(errTo(cb, defer configFilename, configFd))

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
      css_path              = '#{tmpDir}'
      generated_images_path = '#{tmpDir}/_generated'
      javascripts_path      = '#{tmpDir}/_generated' # Rarely used but might as well

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

    await fs.write(configFd, new Buffer(compassConfig), 0, compassConfig.length, null, errTo(cb, defer()))

    await fs.close(configFd, errTo(cb, defer()))

    # Compile the file using Compass
    cmd = path.resolve(__dirname, '..', 'ruby_bundle', 'bin', 'compass')
    args = ['compile', '--config', configFilename, src]

    result = ''
    bundle = spawn(cmd, args)
    bundle.stdout.on 'data', (data) => result += data
    bundle.stderr.on 'data', (data) => result += data
    await bundle.on 'close', defer code

    if code != 0
      result = result.replace(/\n?\s*Use --trace for backtrace./, '')
      message = chalk.bold.red("SASS/COMPASS ERROR") + chalk.bold.black(" (#{code})") + "\n#{result}"
      output.error(src, 'Sass', message)
      return cb('Sass compile failed')

    await
      # Copy any extra files that were generated
      @_copyGeneratedDirectory(
        path.join(tmpDir, '_generated'),
        path.join(@destPath, '_generated')
        errTo(cb, defer())
      )

      # Get the content from the CSS file
      pathFromRoot = path.relative(@srcPath, path.dirname(src)) || '.'
      outputFile = path.join(tmpDir, pathFromRoot, path.basename(src).replace(/\.scss$/, '.css'))
      fs.readFile(outputFile, 'utf8', errTo(cb, defer content))

    # Remove the comments showing the source lines until I can fix them
    # TODO: Rewrite the paths instead of removing them
    content = content.replace(/\/\* line .*? \*\/\n/g, '')

    # Run the callback
    cb(null, content)


  _copyGeneratedFileOrDirectory: (src, dest, file, cb) =>
    return cb() if file[0...1] == '_'

    srcFile = path.join(src, file)
    destFile = path.join(dest, file)

    await fs.lstat(srcFile, errTo(cb, defer stat))

    if stat.isDirectory()
      @_copyGeneratedDirectory(srcFile, destFile, cb)
    else
      @_copyGeneratedFile(srcFile, destFile, cb)


  _copyGeneratedFile: (src, dest, cb) =>
    await fs.readFile(src, errTo(cb, defer content))
    @_writeFile(dest, content: content, 'generated', cb)


  _copyGeneratedDirectory: (src, dest, cb) =>

    # Get a list of files
    await fs.readdir(src, defer(err, files))

    if err
      if err.code == 'ENOENT'
        # Source directory doesn't exist, so there's nothing to do
        return cb()
      else
        return cb(err)

    # Create destination directory
    await mkdirp(dest, errTo(cb, defer()))

    # Copy the files
    async.each(files, _.partial(@_copyGeneratedFileOrDirectory, src, dest), cb)


  _compileFile: (src, dest, cb) =>

    # Compile CoffeeScript
    if src[-7...].toLowerCase() == '.coffee'
      dest = dest[...-7] + '.js'
      await @_compileCoffeeScript(src, errTo(cb, defer content))
      @_writeFile(dest, content: content, 'compiled', cb)

    # Compile Sass
    else if src[-5...].toLowerCase() == '.scss'
      dest = dest[...-5] + '.css'
      await @_compileSass(src, errTo(cb, defer content))
      content = @_rewriteCss(content, src, dest)
      @_writeFile(dest, content: content, 'compiled', cb)

    # Import files listed in a YAML file
    else if src[-9...].toLowerCase() == '.css.yaml'
      dest = dest[...-5]
      await @_compileYamlCss(src, dest, errTo(cb, defer data))
      @_writeFile(dest, data, 'compiled', cb)

    else if src[-8...].toLowerCase() == '.js.yaml'
      dest = dest[...-5]
      await @_compileYamlJs(src, dest, errTo(cb, defer data))
      @_writeFile(dest, data, 'compiled', cb)

    # Copy CSS and replace URLs
    else if src[-4...].toLowerCase() == '.css'
      await fs.readFile(src, 'utf8', errTo(cb, defer content))
      content = @_rewriteCss(content, src, dest)
      @_writeFile(dest, content: content, 'copied', cb)

    # Copy other files
    else
      await fs.readFile(src, errTo(cb, defer content))
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
    await readdir.read(src, null, readdir.CASELESS_SORT, errTo(cb, defer files))

    compile = (file, cb) =>
      return cb() if file[0...1] == '_'

      srcFile = path.join(src, file)

      # Compile Sass
      if srcFile[-5...].toLowerCase() == '.scss'
        await @_compileSass(srcFile, errTo(cb, defer content))
        content = @_rewriteCss(content, srcFile, dest)
        cb(null, content)

      # Other CSS file
      else
        await fs.readFile(srcFile, 'utf8', errTo(cb, defer content))
        content = @_rewriteCss(content, srcFile, dest)
        cb(null, content)

    await async.map(files, compile, errTo(cb, defer content))
    content = _.filter(content)
    cb(null, content: content.join('\n'), count: content.length)


  _compileYamlCss: (yamlFile, dest, cb) =>
    await yamlMap(yamlFile, @bowerSrc, errTo(cb, defer files))

    compile = (file, cb) =>
      return cb() if file[0...1] == '_'

      # Compile Sass
      if file[-5...].toLowerCase() == '.scss'
        await @_compileSass(file, errTo(cb, defer content))
        content = @_rewriteCss(content, file, dest)
        cb(null, content)

      # Other CSS file
      else
        await fs.readFile(file, 'utf8', errTo(cb, defer content))
        content = @_rewriteCss(content, file, dest)
        cb(null, content)

    await async.map(files, compile, errTo(cb, defer content))
    content = _.filter(content)
    cb(null, content: content.join('\n'), count: content.length)


  _compileJsDirectory: (src, dest, cb) =>
    await readdir.read(src, null, readdir.CASELESS_SORT, errTo(cb, defer files))

    compile = (file, cb) =>
      return cb() if file[0...1] == '_'

      srcFile = path.join(src, file)

      # Compile CoffeeScript
      if srcFile[-7...].toLowerCase() == '.coffee'
        @_compileCoffeeScript(srcFile, cb)

      # Other file
      else
        fs.readFile(srcFile, 'utf8', cb)

    await async.map(files, compile, errTo(cb, defer content))
    content = _.filter(content)
    cb(null, content: content.join('\n'), count: content.length)


  _compileYamlJs: (yamlFile, dest, cb) =>
    await yamlMap(yamlFile, @bowerSrc, errTo(cb, defer files))

    compile = (file, cb) =>
      if file[0...1] == '_'
        return cb()

      # Compile CoffeeScript
      if file[-7...].toLowerCase() == '.coffee'
        @_compileCoffeeScript(file, cb)

      # Other file
      else
        fs.readFile(file, 'utf8', cb)

    await async.map(files, compile, errTo(cb, defer content))
    content = _.filter(content)
    cb(null, content: content.join('\n'), count: content.length)


module.exports = AssetGroup
