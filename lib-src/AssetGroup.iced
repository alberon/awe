_            = require('lodash')
async        = require('async')
autoprefixer = require('autoprefixer-core')
cacheDir     = require('./cacheDir')
chalk        = require('chalk')
coffee       = require('coffee-script')
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

  constructor: (@rootPath, config) ->
    @autoprefixer = config.autoprefixer
    @bower        = config.bower

    # Normalise paths
    @srcPath  = path.join(@rootPath, config.src.replace(/\/*$/, ''))
    @destPath = path.join(@rootPath, config.dest.replace(/\/*$/, ''))

    # Generated paths
    @srcLink = path.join(@destPath, '_src')

    if @bower
      @bowerLink = path.join(@destPath, '_bower')
      @bowerSrc  = path.join(@rootPath, @bower)


  build: (cb) =>
    await
      # Check if the source directory exists
      fs.exists(@srcPath, defer(srcExists))

      # Need to know if the destination already exists for the output message
      fs.exists(@destPath, defer(destExists))

      # Also need to check if the Bower directory exists
      bowerExists = false
      if @bower
        fs.exists(@bowerSrc, defer(bowerExists))

    if !srcExists
      output.error(@srcPath, null, "Source directory doesn't exist")
      return cb()

    if !bowerExists
      @bower     = false
      @bowerLink = null
      @bowerSrc  = null

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
      @_createSymlink(@srcPath, @srcLink, errTo(cb, defer()))

      # Create a symlink to the bower_components directory
      if @bower
        @_createSymlink(@bowerSrc, @bowerLink, errTo(cb, defer()))

      # Create cache directory
      cacheDir.prepare(@rootPath, errTo(cb, defer @cachePath))

      # Determine the real path of the root - needed to detect loops
      fs.realpath(@srcPath, errTo(cb, defer srcRealPath))

    # Compile the directory
    @_buildRegularDirectory(@srcPath, @destPath, [srcRealPath], cb)


  _createSymlink: (target, link, cb) =>
    target = path.relative(path.dirname(link), target)
    await fs.symlink(target, link, errTo(cb, defer()))
    output.symlink(link + '/', '-> ' + target)
    cb()


  _write: (data, cb) =>
    return cb() if data.content == null

    await fs.writeFile(data.dest, data.content, errTo(cb, defer()))

    if data.action
      output(data.action, data.dest, "(#{data.count} files)" if data.count > 1)

    cb()


  _preventLoops: (src, stack, cancel, build) =>
    await fs.realpath(src, errTo(cancel, defer srcRealPath))

    if srcRealPath in stack
      output.error(src, '(Symlink)', "Infinite loop detected: '#{src}' points to '#{srcRealPath}'")
      return cancel()

    newStack = stack.concat([srcRealPath])
    build(newStack)


  _buildDirectory: (src, dest, stack, cb) =>
    await @_preventLoops(src, stack, cb, defer newStack)

    if src[-4..].toLowerCase() == '.css' || src[-3..].toLowerCase() == '.js'
      await @_compileDirectory(src, dest, newStack, errTo(cb, defer data))
      @_write(data, cb)

    else
      @_buildRegularDirectory(src, dest, newStack, cb)


  _buildRegularDirectory: (src, dest, stack, cb) =>

    # Get a list of files in the source directory
    await readdir.read(
      src,
      readdir.CASELESS_SORT | readdir.INCLUDE_DIRECTORIES | readdir.NON_RECURSIVE,
      errTo(cb, defer files)
    )

    # Create the destination directory
    await mkdirp(dest, errTo(cb, defer()))

    # Build each of the files/directories in parallel
    build = (file, cb) =>
      return cb() if file[0...1] == '_'

      srcFile = path.join(src, file)
      destFile = path.join(dest, file)

      if file[-1..] == '/'
        @_buildDirectory(srcFile[...-1], destFile[...-1], stack, cb)
      else
        await @_compileFile(srcFile, destFile, stack, errTo(cb, defer data))
        @_write(data, cb)

    async.each(files, build, cb)


  _getFile: (src, dest, cb) =>
    await fs.readFile(src, 'utf8', errTo(cb, defer content))
    cb(null, content: content, count: 1, action: 'copied', dest: dest)


  _compileCoffeeScript: (src, dest, cb) =>
    await @_getFile(src, dest, errTo(cb, defer data))
    data.content = coffee.compile(data.content)
    data.action = 'compiled'
    cb(null, data)


  _getCss: (src, dest, cb) =>
    await @_getFile(src, dest, errTo(cb, defer data))
    data.content = @_rewriteCss(data.content, src, dest)
    cb(null, data)


  _compileSass: (src, dest, cb) =>

    # Create a temp directory for the output
    await tmp.dir(unsafeCleanup: true, errTo(cb, defer tmpDir))

    # Create a config file for Compass
    # (Compass doesn't let us specify all options using the CLI, so we have to
    # generate a config file instead. We could use `sass --compass` instead for
    # some of them, but that doesn't support all the options either.)
    await tmp.file(errTo(cb, defer configFilename, configFd))

    compassConfig = """
      project_path = '#{@rootPath}'
      cache_path   = '#{path.join(@cachePath, 'sass-cache')}'
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
      # Note: Can't use getCss here because the original src is different to the file we're reading
      @_getFile(outputFile, dest, errTo(cb, defer data))

    # Remove the comments showing the source lines until I can fix them
    # TODO: Rewrite the paths instead of removing them
    data.content = data.content.replace(/\/\* line .*? \*\/\n/g, '')

    # Rewrite the URLs in the CSS
    data.content = @_rewriteCss(data.content, src, dest)

    data.action = 'compiled'

    # Run the callback
    cb(null, data)


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
    await @_getFile(src, dest, errTo(cb, defer data))
    data.action = 'generated'
    @_write(data, cb)


  _copyGeneratedDirectory: (src, dest, cb) =>

    # Get a list of files
    await fs.readdir(src, defer(err, files))

    if err && err.code == 'ENOENT'
      # Source directory doesn't exist, so there's nothing to do
      return cb()
    else if err
      return cb(err)

    # Create destination directory
    await mkdirp(dest, errTo(cb, defer()))

    # Copy the files
    async.each(files, _.partial(@_copyGeneratedFileOrDirectory, src, dest), cb)


  _compileFile: (src, dest, stack, cb) =>
    await @_preventLoops(src, stack, cb, defer newStack)

    # Compile directory (used for recursion)
    if src[-1..] == '/'
      @_compileDirectory(src[...-1], dest[...-1], newStack, cb)

    # Compile CoffeeScript
    else if src[-7..].toLowerCase() == '.coffee'
      @_compileCoffeeScript(src, dest[...-7] + '.js', cb)

    # Compile Sass
    else if src[-5..].toLowerCase() == '.scss'
      @_compileSass(src, dest[...-5] + '.css', cb)

    # Import files listed in a YAML file
    else if src[-9..].toLowerCase() == '.css.yaml' || src[-8..].toLowerCase() == '.js.yaml'
      @_compileYamlImports(src, dest[...-5], newStack, cb)

    # Copy CSS and replace URLs
    else if src[-4..].toLowerCase() == '.css'
      @_getCss(src, dest, cb)

    # Copy other files
    else
      @_getFile(src, dest, cb)


  _rewriteCss: (content, srcFile, destFile) =>
    urlRewriter = new UrlRewriter
      root:      @rootPath
      srcDir:    @srcPath
      srcFile:   srcFile
      destDir:   @destPath
      destFile:  destFile
      bowerSrc:  @bowerSrc
      bowerDest: @bowerLink

    # URL rewriting
    content = css.rewriteUrls content, (url) =>
      if S(url).startsWith('/AWEDESTROOTPATH/')
        return path.join(path.relative(path.dirname(srcFile), @srcPath), url[17..])

      try
        urlRewriter.rewrite(url)
      catch e
        output.warning(srcFile, '(URL rewriter)', e.message)
        return url

    # Autoprefixer
    if @autoprefixer
      content = autoprefixer.process(content).css

    return content


  _compileMultipleFiles: (files, dest, stack, cb) =>
    count = 0

    compile = (file, cb) =>
      await @_compileFile(file, dest, stack, errTo(cb, defer data))
      return cb() unless data
      count += data.count
      cb(null, data.content)

    await async.map(files, compile, errTo(cb, defer content))
    content = _.filter(content)
    cb(null, content: content.join('\n'), count: count, action: 'compiled', dest: dest)


  _compileDirectory: (src, dest, stack, cb) =>
    await readdir.read(
      src,
      readdir.CASELESS_SORT | readdir.INCLUDE_DIRECTORIES | readdir.NON_RECURSIVE,
      errTo(cb, defer files)
    )

    # Remove files starting with _
    files = files.filter (file) -> file[0...1] != '_'

    # Convert to absolute paths
    files = files.map (file) -> path.join(src, file)

    @_compileMultipleFiles(files, dest, stack, cb)


  _compileYamlImports: (yamlFile, dest, stack, cb) =>
    await yamlMap(yamlFile, @srcPath, @bowerSrc, errTo(cb, defer files))
    @_compileMultipleFiles(files, dest, stack, cb)


module.exports = AssetGroup