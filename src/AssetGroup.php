<?php
namespace Alberon\Awe;

use Illuminate\Filesystem\Filesystem;

class AssetGroup
{
    // tmp.setGracefulCleanup()

    // bundlePath  = path.resolve(__dirname, '..', 'ruby_bundle')
    // compassPath = path.resolve(__dirname, '..', 'ruby_bundle', 'bin', 'compass')

    protected $app;
    protected $autoprefixer;
    protected $bower;
    protected $bowerLink;
    protected $bowerSrc;
    protected $destPath;
    protected $file;
    protected $rootPath;
    protected $sourcemaps;
    protected $srcPath;
    protected $warningFile;

    public function __construct($rootPath, $config, App $app, Filesystem $file)
    {
        // Dependencies
        $this->app = $app;
        $this->file = $file;

        // Data
        $this->rootPath = rtrim($rootPath, '/\\');

        $this->autoprefixer = $config['autoprefixer'];
        $this->bower        = $config['bower'];
        $this->sourcemaps   = $config['sourcemaps'];

        // Normalise paths
        $this->srcPath  = $this->rootPath . '/' . rtrim($config['src'], '/\\');
        $this->destPath = $this->rootPath . '/' . rtrim($config['dest'], '/\\');

        // Generated paths
        if ($this->bower) {
            $this->bowerLink = $this->destPath . '/_bower';
            $this->bowerSrc  = $this->rootPath . '/' . $this->bower;
        }

        if ($config['warningfile'])
            $this->warningFile = $this->destPath . '/_DO_NOT_EDIT.txt';
        else
            $this->warningFile = false;
    }

    public function build()
    {
        // Check if the source directory exists
        $srcExists = $this->file->exists($this->srcPath);

        // Need to know if the destination already exists for the output message
        $destExists = $this->file->exists($this->destPath);

        // # Also need to check if the Bower directory exists
        // bowerExists = false
        // if @bower
        // fs.exists(@bowerSrc, defer bowerExists)

        //     if !srcExists
        //       file = path.relative(@rootPath, @srcPath)
        //       output.error(file, null, "Source directory doesn't exist")
        //       return cb()

        //     if !bowerExists
        //       output.warning(@bower, null, 'Bower directory does not exist') if @bower
        //       @bower     = false
        //       @bowerLink = null
        //       @bowerSrc  = null

        // Delete the destination
        $this->file->deleteDirectory($this->destPath);

        //     file = path.relative(@rootPath, @destPath + '/')
        //     if destExists
        //       output.emptied(file)
        //     else
        //       output.created(file)

        //     await
        //       # Create a symlink to the bower_components directory
        //       if @bower
        //         @_createSymlink(@bowerSrc, @bowerLink, errTo(cb, defer()))

        //       # Create a file warning people not to edit the compiled files
        //       if @warningFile
        //         stream = mu.compileAndRender 'asset-warning.mustache',
        //           source: path.relative(@destPath, @srcPath)
        //         @_write(dest: path.join(@warningFile), stream: stream, action: 'generated', defer())

        //       # Create cache directory
        //       cacheDir.prepare(@rootPath, errTo(cb, defer @cachePath))

        //       # Determine the real path of the root - needed to detect loops
        //       fs.realpath(@srcPath, errTo(cb, defer srcRealPath))

        // Compile the directory
        $this->buildRegularDirectory($this->srcPath, $this->destPath);
    }

    //   _createSymlink: (target, link, cb) =>
    //     target = path.relative(path.dirname(link), target)
    //     await fs.symlink(target, link, errTo(cb, defer()))
    //     file = path.relative(@rootPath, link + '/')
    //     output.symlink(file, '-> ' + target)
    //     cb()


    //   _addSourceMapComment: (data) =>
    //     if data.dest[-3...].toLowerCase() == '.js'
    //       # Note: This is split into two strings to avoid interfering with source-map-support regex
    //       data.content += "\n//" + "# sourceMappingURL=#{path.basename(data.dest)}.map\n"
    //     else if data.dest[-4...].toLowerCase() == '.css'
    //       data.content += "\n/*# sourceMappingURL=#{path.basename(data.dest)}.map */\n"
    //     else
    //       throw new Exception("Don't know how to add a source map comment to '#{data.dest}'")


    //   _removeSourceMapComment: (data) =>
    //     # This is for when an external library (PostCSS, Sass) adds a comment we
    //     # don't want (because we want to combine files and then add the comment at
    //     # the very end)
    //     data.content = data.content.replace(/[\r\n]*\/\*# sourceMappingURL=[^ ]+ \*\/[\r\n]*$/, '\n')


    //   _parseSourceMap: (sourcemap) =>
    //     if typeof sourcemap is 'string'
    //       sourcemap = JSON.parse(sourcemap)

    //     # Ignore files with no mappings work around "Invalid mapping" and
    //     # "Unsupported previous source map format" errors
    //     if !sourcemap || !sourcemap.mappings
    //       return null

    //     return sourcemap


    //   _inlineSourceMapContent: (data, cb) =>
    //     sourceToContent = (file, cb) =>
    //       await fs.readFile(path.join(@srcPath, file), 'utf8', errTo(cb, defer content))
    //       content = content.replace(/\r\n/g, "\n") # Firefox doesn't like Windows line endings
    //       cb(null, content)

    //     await async.map(data.sourcemap.sources, sourceToContent, errTo(cb, defer contents))
    //     data.sourcemap.sourcesContent = contents
    //     cb()


    //   _rewriteSourceMapFilenames: (data) =>
    //     for source, k in data.sourcemap.sources
    //       source = path.resolve(@srcPath, source)

    //       # Compass sometimes adds its own internal files to the sourcemap which
    //       # results in ugly ../../../ paths - rewrite them to something readable.
    //       # Note: This has to be done *after* _inlineSourceMapContent() is called.
    //       if S(source).startsWith(bundlePath)
    //         data.sourcemap.sources[k] = '_awe/ruby_bundle' + source[bundlePath.length...]


    protected function write($data)
    {
        if (!$data || $data['content'] === null)
            return;

        // if @sourcemaps && data.sourcemap
        //   data.sourcemap.sourceRoot = path.relative(path.dirname(data.dest), @srcPath)
        //   await @_inlineSourceMapContent(data, errTo(cb, defer()))
        //   @_rewriteSourceMapFilenames(data)
        //   @_addSourceMapComment(data)

        // await
        //   if @sourcemaps && data.sourcemap
        //     sourcemap = JSON.stringify(data.sourcemap, null, '  ')
        //     fs.writeFile("#{data.dest}.map", sourcemap, errTo(cb, defer()))

        $this->file->put($data['dest'], $data['content']);

        // if data.action
        //   file = path.relative(@rootPath, data.dest)
        //   output(data.action, file, "(#{data.count} files)" if data.count > 1)
    }

    protected function buildFileOrDirectory($src, $dest)
    {
        if ($this->file->isDirectory($src)) {
            $this->buildDirectory($src, $dest);
        } else {
            $data = $this->compileFile($src, $dest);
            $this->write($data);
        }
    }

    // _buildDirectory: (src, dest, cb) =>
    //   if src[-4..].toLowerCase() == '.css' || src[-3..].toLowerCase() == '.js'
    //     await @_compileDirectory(src, dest, errTo(cb, defer data))
    //     @_write(data, cb)

    //   else
    //     @_buildRegularDirectory(src, dest, cb)

    protected function readDirectory($dir)
    {
        $finder = $this->app->make('Symfony\Component\Finder\Finder');

        $files = [];
        foreach ($finder->in($dir)->depth(0) as $file) {
            $files[] = $file->getRelativePathname();
        }

        if ($files === false)
            return [];

        natcasesort($files);

        return $files;
    }

    protected function buildRegularDirectory($src, $dest)
    {
        // Create the destination directory
        $this->file->makeDirectory($dest, 0777, true);

        // Get a list of files in the source directory
        $files = $this->readDirectory($src);

        // Build each of the files/directories
        foreach ($files as $file) {
            if ($file[0] === '_')
                continue;

            $srcFile  = $src . '/' . $file;
            $destFile = $dest . '/' . $file;

            $this->buildFileOrDirectory($srcFile, $destFile);
        }
    }

    protected function getFile($src, $dest)
    {
        return [
            'content' => $this->file->get($src),
            'count'   => 1,
            'action'  => 'copied',
            'dest'    => $dest,
        ];
    }

    //   _compileCoffeeScript: (src, dest, cb) =>
    //     await @_getFile(src, dest, errTo(cb, defer data))

    //     try
    //       result = coffee.compile(data.content,
    //         sourceMap:     true
    //         sourceFiles:   [path.relative(@srcPath, src)]
    //         generatedFile: path.basename(dest)
    //       )
    //     catch e
    //       file = path.relative(@rootPath, src)
    //       output.error(file, null, e.toString().replace('[stdin]:', ''))
    //       return cb()

    //     data.content = result.js
    //     data.sourcemap = @_parseSourceMap(result.v3SourceMap)
    //     data.action = 'compiled'

    //     cb(null, data)


    //   _getCss: (src, dest, cb) =>
    //     await @_getFile(src, dest, errTo(cb, defer data))
    //     @_rewriteCss(data, src, dest)
    //     cb(null, data)


    //   _compileSass: (src, dest, cb) =>

    //     # Create a temp directory for the output
    //     await tmp.dir(unsafeCleanup: true, errTo(cb, defer tmpDir))

    //     # Create a config file for Compass
    //     # (Compass doesn't let us specify all options using the CLI, so we have to
    //     # generate a config file instead. We could use `sass --compass` instead for
    //     # some of them, but that doesn't support all the options either.)
    //     await tmp.file(errTo(cb, defer configFilename, configFd))

    //     compassConfig = """
    //       project_path = '#{@rootPath}'
    //       cache_path   = '#{path.join(@cachePath, 'sass-cache')}'
    //       output_style = :expanded

    //       # Input files
    //       sass_path        =  '#{@srcPath}'
    //       images_path      =  '#{@srcPath}/img'
    //       fonts_path       =  '#{@srcPath}/fonts'
    //       sprite_load_path << '#{@srcPath}/_sprites'

    //       # Output to a temp directory so we can catch any generated files too
    //       css_path              = '#{tmpDir}'
    //       generated_images_path = '#{tmpDir}/_generated'
    //       javascripts_path      = '#{tmpDir}/_generated' # Rarely used but might as well

    //       # Output a placeholder for URLs - we will rewrite them into relative paths later
    //       # (Can't use 'relative_assets' because it generates paths like '../../../tmp/tmp-123/img')
    //       http_path                  = '/AWEDESTROOTPATH'
    //       http_stylesheets_path      = '/AWEDESTROOTPATH'
    //       http_images_path           = '/AWEDESTROOTPATH/img'
    //       http_fonts_path            = '/AWEDESTROOTPATH/fonts'
    //       http_generated_images_path = '/AWEDESTROOTPATH/_generated'
    //       http_javascripts_path      = '/AWEDESTROOTPATH/_generated'

    //       # Disable cache busting URLs (e.g. sample.gif?123456) - it makes unit
    //       # testing harder! One day I'll add cache busting URLs in a PostCSS filter
    //       asset_cache_buster :none

    //       # Disable line number comments - use sourcemaps instead
    //       line_comments = false
    //       sourcemap = #{if @sourcemaps then 'true' else 'false'}
    //     """

    //     await fs.write(configFd, new Buffer(compassConfig), 0, compassConfig.length, null, errTo(cb, defer()))

    //     await fs.close(configFd, errTo(cb, defer()))

    //     # Compile the file using Compass
    //     args = ['compile', '--trace', '--config', configFilename, src]

    //     result = ''
    //     bundle = spawn(compassPath, args)
    //     bundle.stdout.on 'data', (data) => result += data
    //     bundle.stderr.on 'data', (data) => result += data
    //     await bundle.on 'close', defer code

    //     if code != 0
    //       result = result.replace(/\n?\s*Use --trace for backtrace./, '')
    //       message = chalk.bold.red("SASS/COMPASS ERROR") + chalk.bold.black(" (#{code})") + "\n#{result}"
    //       file = path.relative(@rootPath, src)
    //       output.error(file, null, message)
    //       return cb()

    //     await
    //       # Copy any extra files that were generated
    //       @_copyGeneratedDirectory(
    //         path.join(tmpDir, '_generated'),
    //         path.join(@destPath, '_generated')
    //         errTo(cb, defer())
    //       )

    //       # Get the content from the CSS file
    //       pathFromRoot = path.relative(@srcPath, path.dirname(src)) || '.'
    //       outputFile = path.join(tmpDir, pathFromRoot, path.basename(src).replace(/\.scss$/, '.css'))
    //       @_getFile(outputFile, dest, errTo(cb, defer data))

    //       # Get the content from the source map
    //       if @sourcemaps
    //         fs.readFile("#{outputFile}.map", 'utf8', errTo(cb, defer sourcemap))

    //     if @sourcemaps
    //       data.sourcemap = @_parseSourceMap(sourcemap)

    //       # Make the sources relative to the source directory - we'll change them
    //       # to be relative to the final destination file later
    //       if data.sourcemap
    //         for source, k in data.sourcemap.sources
    //           source = path.resolve(path.dirname(outputFile), source)
    //           data.sourcemap.sources[k] = path.relative(@srcPath, source)

    //       @_removeSourceMapComment(data)

    //     # Rewrite the URLs in the CSS
    //     @_rewriteCss(data, src, dest)

    //     data.action = 'compiled'

    //     # Run the callback
    //     cb(null, data)


    //   _copyGeneratedFileOrDirectory: (src, dest, file, cb) =>
    //     return cb() if file[0...1] == '_'

    //     srcFile = path.join(src, file)
    //     destFile = path.join(dest, file)

    //     await fs.stat(srcFile, errTo(cb, defer stat))

    //     if stat.isDirectory()
    //       @_copyGeneratedDirectory(srcFile, destFile, cb)
    //     else
    //       @_copyGeneratedFile(srcFile, destFile, cb)


    //   _copyGeneratedFile: (src, dest, cb) =>
    //     await @_getFile(src, dest, errTo(cb, defer data))
    //     data.action = 'generated'
    //     @_write(data, cb)


    //   _copyGeneratedDirectory: (src, dest, cb) =>

    //     # Get a list of files
    //     await fs.readdir(src, defer(err, files))

    //     if err && err.code == 'ENOENT'
    //       # Source directory doesn't exist, so there's nothing to do
    //       return cb()
    //     else if err
    //       return cb(err)

    //     # Create destination directory
    //     await mkdirp(dest, errTo(cb, defer()))

    //     # Copy the files
    //     async.each(files, _.partial(@_copyGeneratedFileOrDirectory, src, dest), cb)


    protected function compileFile($src, $dest)
    {
        // # Compile CoffeeScript
        // if src[-7..].toLowerCase() == '.coffee'
        //   @_compileCoffeeScript(src, dest.replace(/\.coffee$/i, '.js'), cb)

        // # Compile Sass
        // else if src[-5..].toLowerCase() == '.scss'
        //   @_compileSass(src, dest.replace(/\.scss$/i, '.css'), cb)

        // # Import files listed in a YAML file
        // else if src[-9..].toLowerCase() == '.css.yaml' || src[-8..].toLowerCase() == '.js.yaml'
        //   @_compileYamlImports(src, dest.replace(/\.yaml$/i, ''), cb)

        // # Copy CSS and replace URLs
        // else if src[-4..].toLowerCase() == '.css'
        //   @_getCss(src, dest, cb)

        // # Copy JavaScript as a string
        // else if src[-3..].toLowerCase() == '.js'
        return $this->getFile($src, $dest);

        // # Copy other files in binary mode (side-effect: they are ignored when in a .js or .css directory)
        // else
        //   @_getFile(src, dest, cb)
    }


    //   _rewriteCss: (data, srcFile, destFile) =>
    //     urlRewriter = new UrlRewriter
    //       root:      @rootPath
    //       srcDir:    @srcPath
    //       srcFile:   srcFile
    //       destDir:   @destPath
    //       destFile:  destFile
    //       bowerSrc:  @bowerSrc
    //       bowerDest: @bowerLink

    //     rewriteUrl = (url) =>
    //       if S(url).startsWith('/AWEDESTROOTPATH/')
    //         return path.join(path.relative(path.dirname(srcFile), @srcPath), url[17..])

    //       try
    //         urlRewriter.rewrite(url)
    //       catch e
    //         file = path.relative(@rootPath, srcFile)
    //         output.warning(file, '(URL rewriter)', e.message)
    //         return url

    //     # PostCSS expects input sourcemap paths to be relative to the new source file
    //     if data.sourcemap
    //       srcDir = path.dirname(srcFile)
    //       for source, k in data.sourcemap.sources
    //         data.sourcemap.sources[k] = path.relative(srcDir, path.resolve(@srcPath, source))

    //     try
    //       result = rewriteCss(
    //         data.content,
    //         path.relative(@srcPath, srcFile),
    //         destFile,
    //         sourcemap: @sourcemaps,
    //         prevSourcemap: data.sourcemap,
    //         autoprefixer: @autoprefixer,
    //         rewriteUrls: rewriteUrl
    //       )
    //     catch e
    //       throw e unless e.source # Looks like a CSS error
    //       file = path.relative(@rootPath, srcFile)
    //       message = "Invalid CSS:\n#{e.reason} on line #{e.line} column #{e.column}"
    //       output.warning(file, '(CSS)', message)
    //       return

    //     data.content = result.css

    //     if @sourcemaps
    //       data.sourcemap = result.map.toJSON()
    //       @_removeSourceMapComment(data)


    //   _compileMultipleFiles: (files, dest, cb) =>
    //     compile = (file, cb) =>
    //       await @_compileFileOrDirectory(file, dest, errTo(cb, defer data))
    //       data.src = file if data
    //       cb(null, data)

    //     # Can't use async.each because they must be concatenated in order
    //     await async.map(files, compile, errTo(cb, defer datas))

    //     concat = new Concat(true, path.basename(dest), '\n');
    //     count = 0

    //     for data in datas
    //       # Skip files with compile errors
    //       if data
    //         # Skip non-text files (TODO: Make this smarter - warn instead about non-
    //         # text files inside a combined directory instead)
    //         if data.content
    //           concat.add(data.src, data.content, data.sourcemap)
    //         count += data.count

    //     sourcemap = @_parseSourceMap(concat.sourceMap)

    //     # Convert absolute paths to relative
    //     if sourcemap
    //       for source, k in sourcemap.sources
    //         # It may already be relative (I'm not sure under what circumstances but
    //         # it happens in the unit tests), in which case we can either try to work
    //         # out whether it's absolute or not, or we can convert it to always be
    //         # absolute first - I've chosen the latter. Node.js 0.11 will add
    //         # path.isAbsolute() which will make the former easier in the future.
    //         source = path.resolve(@srcPath, source)
    //         # And now we can convert it from absolute to relative
    //         sourcemap.sources[k] = path.relative(@srcPath, source)

    //     cb(null, content: concat.content, sourcemap: sourcemap, count: count, action: 'compiled', dest: dest)


    //   _compileFileOrDirectory: (src, dest, cb) =>
    //     await fs.stat(src, errTo(cb, defer stat))

    //     if stat.isDirectory()
    //       @_compileDirectory(src, dest, cb)
    //     else
    //       @_compileFile(src, dest, cb)


    //   _compileDirectory: (src, dest, cb) =>
    //     await @_readDirectory(src, errTo(cb, defer files))

    //     # Remove files starting with _
    //     files = files.filter (file) -> file[0...1] != '_'

    //     # Convert to absolute paths
    //     files = files.map (file) -> path.join(src, file)

    //     @_compileMultipleFiles(files, dest, cb)


    //   _compileYamlImports: (yamlFile, dest, cb) =>
    //     await yamlMap(yamlFile, @bowerSrc, errTo(cb, defer files))

    //     await @_compileMultipleFiles(files, dest, defer(err, data))

    //     if !err
    //       cb(null, data)
    //     else if err.code == 'ENOENT'
    //       file = path.relative(@srcPath, yamlFile)
    //       output.error(file, '(YAML import map)', 'File not found: ' + err.path)
    //       cb()
    //     else
    //       cb(err)


    // module.exports = AssetGroup
}