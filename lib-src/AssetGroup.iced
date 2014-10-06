_            = require('lodash')
async        = require('async')
autoprefixer = require('autoprefixer-core')
cacheDir     = require('./cacheDir')
chalk        = require('chalk')
coffee       = require('coffee-script')
Concat       = require('concat-with-sourcemaps')
errTo        = require('errto')
fs           = require('fs')
mkdirp       = require('mkdirp')
output       = require('./output')
path         = require('path')
rewriteCss   = require('./rewriteCss')
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
    @sourcemaps   = config.sourcemaps

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
      fs.exists(@srcPath, defer srcExists)

      # Need to know if the destination already exists for the output message
      fs.exists(@destPath, defer destExists)

      # Also need to check if the Bower directory exists
      bowerExists = false
      if @bower
        fs.exists(@bowerSrc, defer bowerExists)

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
      if @sourcemaps
        @_createSymlink(@srcPath, @srcLink, errTo(cb, defer()))

      # Create a symlink to the bower_components directory
      if @bower
        @_createSymlink(@bowerSrc, @bowerLink, errTo(cb, defer()))

      # Create cache directory
      cacheDir.prepare(@rootPath, errTo(cb, defer @cachePath))

      # Determine the real path of the root - needed to detect loops
      fs.realpath(@srcPath, errTo(cb, defer srcRealPath))

    # Compile the directory
    @_buildRegularDirectory(@srcPath, @destPath, [], cb)


  _createSymlink: (target, link, cb) =>
    target = path.relative(path.dirname(link), target)
    await fs.symlink(target, link, errTo(cb, defer()))
    output.symlink(link + '/', '-> ' + target)
    cb()


  _addSourceMapComment: (data) =>
    if data.dest[-3...].toLowerCase() == '.js'
      # Note: This is split into two strings to avoid interfering with source-map-support regex
      data.content += "\n//" + "# sourceMappingURL=#{path.basename(data.dest)}.map\n"
    else if data.dest[-4...].toLowerCase() == '.css'
      data.content += "\n/*# sourceMappingURL=#{path.basename(data.dest)}.map */\n"
    else
      throw new Exception("Don't know how to add a source map comment to '#{data.dest}'")


  _removeSourceMapComment: (data) =>
    # This is for when an external library (PostCSS, Sass) adds a comment we
    # don't want (because we want to combine files and then add the comment at
    # the very end)
    data.content = data.content.replace(/[\r\n]*\/\*# sourceMappingURL=[^ ]+ \*\/[\r\n]*$/, '\n')


  _write: (data, cb) =>
    return cb() if data.content == null

    await
      if @sourcemaps && data.sourcemap
        @_addSourceMapComment(data)
        data.sourcemap.sourceRoot = path.relative(path.dirname(data.dest), @srcLink)
        sourcemap = JSON.stringify(data.sourcemap, null, '  ')

        fs.writeFile("#{data.dest}.map", sourcemap, errTo(cb, defer()))

      fs.writeFile(data.dest, data.content, errTo(cb, defer()))

    if data.action
      output(data.action, data.dest, "(#{data.count} files)" if data.count > 1)

    cb()


  _preventLoops: (src, stack, cancel, build) =>
    await fs.realpath(src, errTo(cancel, defer srcRealPath))

    if srcRealPath in stack
      output.error(src, '(Symlink)', "Infinite loop detected: '#{src}' points to '#{srcRealPath}'")
      return cancel()

    stack = stack.concat([srcRealPath])
    build(stack)


  _buildFileOrDirectory: (src, dest, stack, cb) =>
    await fs.stat(src, errTo(cb, defer stat))

    if stat.isDirectory()
      @_buildDirectory(src, dest, stack, cb)

    else
      await @_compileFile(src, dest, stack, errTo(cb, defer data))
      @_write(data, cb)


  _buildDirectory: (src, dest, stack, cb) =>
    if src[-4..].toLowerCase() == '.css' || src[-3..].toLowerCase() == '.js'
      await @_compileDirectory(src, dest, stack, errTo(cb, defer data))
      @_write(data, cb)

    else
      @_buildRegularDirectory(src, dest, stack, cb)


  _readDirectory: (dir, cb) =>
    await fs.readdir(dir, errTo(cb, defer files))

    files = files.sort (a, b) ->
      a = a.toLowerCase()
      b = b.toLowerCase()

      switch
        when a == b then 0
        when a > b then 1
        else -1

    cb(null, files)


  _buildRegularDirectory: (src, dest, stack, cb) =>
    await @_preventLoops(src, stack, cb, defer stack)

    # Get a list of files in the source directory
    await @_readDirectory(src, errTo(cb, defer files))

    # Create the destination directory
    await mkdirp(dest, errTo(cb, defer()))

    # Build each of the files/directories in parallel
    build = (file, cb) =>
      return cb() if file[0...1] == '_'

      srcFile  = path.join(src, file)
      destFile = path.join(dest, file)

      @_buildFileOrDirectory(srcFile, destFile, stack, cb)

    async.each(files, build, cb)


  _getFile: (src, dest, cb) =>
    await fs.readFile(src, 'utf8', errTo(cb, defer content))
    cb(null, content: content, count: 1, action: 'copied', dest: dest)


  _compileCoffeeScript: (src, dest, cb) =>
    await @_getFile(src, dest, errTo(cb, defer data))

    result = coffee.compile(data.content,
      sourceMap:     true
      sourceFiles:   [path.relative(@srcPath, src)]
      generatedFile: path.basename(dest)
    )

    data.content = result.js
    data.sourcemap = JSON.parse(result.v3SourceMap)
    data.action = 'compiled'

    cb(null, data)


  _getCss: (src, dest, cb) =>
    await @_getFile(src, dest, errTo(cb, defer data))
    @_rewriteCss(data, src, dest)
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

      # Disable line number comments - use sourcemaps instead
      line_comments = false
      sourcemap = #{if @sourcemaps then 'true' else 'false'}
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
      @_getFile(outputFile, dest, errTo(cb, defer data))

      # Get the content from the source map
      if @sourcemaps
        fs.readFile("#{outputFile}.map", 'utf8', errTo(cb, defer sourcemap))

    if @sourcemaps
      data.sourcemap = JSON.parse(sourcemap)

      # Make the sources relative to the source directory - we'll change them
      # to be relative to the final destination file later
      for source, i in data.sourcemap.sources
        source = path.resolve(path.dirname(outputFile), source)
        data.sourcemap.sources[i] = path.relative(@srcPath, source)

      @_removeSourceMapComment(data)

    # Rewrite the URLs in the CSS
    @_rewriteCss(data, src, dest)

    data.action = 'compiled'

    # Run the callback
    cb(null, data)


  _copyGeneratedFileOrDirectory: (src, dest, file, cb) =>
    return cb() if file[0...1] == '_'

    srcFile = path.join(src, file)
    destFile = path.join(dest, file)

    await fs.stat(srcFile, errTo(cb, defer stat))

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
    # Compile CoffeeScript
    if src[-7..].toLowerCase() == '.coffee'
      @_compileCoffeeScript(src, dest.replace(/\.coffee$/i, '.js'), cb)

    # Compile Sass
    else if src[-5..].toLowerCase() == '.scss'
      @_compileSass(src, dest.replace(/\.scss$/i, '.css'), cb)

    # Import files listed in a YAML file
    else if src[-9..].toLowerCase() == '.css.yaml' || src[-8..].toLowerCase() == '.js.yaml'
      @_compileYamlImports(src, dest.replace(/\.yaml$/i, ''), stack, cb)

    # Copy CSS and replace URLs
    else if src[-4..].toLowerCase() == '.css'
      @_getCss(src, dest, cb)

    # Copy other files
    else
      @_getFile(src, dest, cb)


  _rewriteCss: (data, srcFile, destFile) =>
    urlRewriter = new UrlRewriter
      root:      @rootPath
      srcDir:    @srcPath
      srcFile:   srcFile
      destDir:   @destPath
      destFile:  destFile
      bowerSrc:  @bowerSrc
      bowerDest: @bowerLink

    # PostCSS expects input sourcemap paths to be relative to the new source file
    if data.sourcemap
      srcDir = path.dirname(srcFile)
      for source, k in data.sourcemap.sources
        data.sourcemap.sources[k] = path.relative(srcDir, path.resolve(@srcPath, source))

    result = rewriteCss data.content, path.relative(@srcPath, srcFile), destFile, sourcemap: @sourcemaps, prevSourcemap: data.sourcemap, autoprefixer: @autoprefixer, rewriteUrls: (url) =>
      if S(url).startsWith('/AWEDESTROOTPATH/')
        return path.join(path.relative(path.dirname(srcFile), @srcPath), url[17..])

      try
        urlRewriter.rewrite(url)
      catch e
        output.warning(srcFile, '(URL rewriter)', e.message)
        return url

    data.content = result.css

    if @sourcemaps
      data.sourcemap = result.map.toJSON()
      @_removeSourceMapComment(data)


  _compileMultipleFiles: (files, dest, stack, cb) =>
    compile = (file, cb) =>
      await @_compileFileOrDirectory(file, dest, stack, errTo(cb, defer data))
      data.src = file if data
      cb(null, data)

    # Can't use async.each because they must be concatenated in order
    await async.map(files, compile, errTo(cb, defer datas))

    concat = new Concat(true, path.basename(dest), '\n');
    count = 0

    for data in datas
      if data && data.content
        concat.add(data.src, data.content, data.sourcemap)
        count += data.count

    sourcemap = JSON.parse(concat.sourceMap)

    # Convert absolute paths to relative
    if sourcemap
      for source, k in sourcemap.sources
        # It may already be relative (I'm not sure under what circumstances but
        # it happens in the unit tests), in which case we can either try to work
        # out whether it's absolute or not, or we can convert it to always be
        # absolute first - I've chosen the latter. Node.js 0.11 will add
        # path.isAbsolute() which will make the former easier in the future.
        source = path.resolve(@srcPath, source)
        # And now we can convert it from absolute to relative
        sourcemap.sources[k] = path.relative(@srcPath, source)

    cb(null, content: concat.content, sourcemap: sourcemap, count: count, action: 'compiled', dest: dest)


  _compileFileOrDirectory: (src, dest, stack, cb) =>
    await fs.stat(src, errTo(cb, defer stat))

    if stat.isDirectory()
      @_compileDirectory(src, dest, stack, cb)
    else
      @_compileFile(src, dest, stack, cb)


  _compileDirectory: (src, dest, stack, cb) =>
    await @_preventLoops(src, stack, cb, defer stack)

    await @_readDirectory(src, errTo(cb, defer files))

    # Remove files starting with _
    files = files.filter (file) -> file[0...1] != '_'

    # Convert to absolute paths
    files = files.map (file) -> path.join(src, file)

    @_compileMultipleFiles(files, dest, stack, cb)


  _compileYamlImports: (yamlFile, dest, stack, cb) =>
    await yamlMap(yamlFile, @srcPath, @bowerSrc, errTo(cb, defer files))
    @_compileMultipleFiles(files, dest, stack, cb)


module.exports = AssetGroup
