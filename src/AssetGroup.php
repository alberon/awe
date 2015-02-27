<?php
namespace Alberon\Awe;

use Illuminate\Filesystem\Filesystem;

class AssetGroup
{
    // tmp.setGracefulCleanup()

    // bundlePath  = path.resolve(__dirname, '..', 'ruby_bundle')

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
        $this->srcPath  = $this->rootPath . DIRECTORY_SEPARATOR . rtrim($config['src'], '/\\');
        $this->destPath = $this->rootPath . DIRECTORY_SEPARATOR . rtrim($config['dest'], '/\\');

        // Generated paths
        if ($this->bower) {
            $this->bowerLink = $this->destPath . DIRECTORY_SEPARATOR . '_bower';
            $this->bowerSrc  = $this->rootPath . DIRECTORY_SEPARATOR . $this->bower;
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

        // Create cache directory
        $this->cachePath = $this->rootPath . DIRECTORY_SEPARATOR . '.awe';
        if (!is_dir($this->cachePath))
            mkdir($this->cachePath);

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

    protected function parseSourceMap($sourcemap)
    {
        return json_decode($sourcemap);

        // if typeof sourcemap is 'string'
        //   sourcemap = JSON.parse(sourcemap)

        // # Ignore files with no mappings work around "Invalid mapping" and
        // # "Unsupported previous source map format" errors
        // if !sourcemap || !sourcemap.mappings
        //   return null

        // return sourcemap
    }


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

    protected function buildDirectory($src, $dest)
    {
        $file = strtolower($src);

        if (substr($file, -4) === '.css' || substr($file, -3) === '.js') {
            $data = $this->compileDirectory($src, $dest);
            $this->write($data);
        } else {
            $this->buildRegularDirectory($src, $dest);
        }
    }

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

            $srcFile  = $src . DIRECTORY_SEPARATOR . $file;
            $destFile = $dest . DIRECTORY_SEPARATOR . $file;

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

    protected function compileCoffeeScript($src, $dest)
    {
        $script       = dirname(__DIR__) . '/node/compile-coffeescript.coffee';
        $relativeSrc  = $this->relpath($this->srcPath, $src);
        $destFilename = basename($dest);

        $exe  = dirname(__DIR__) . '/node_modules/.bin/coffee';
        $args = [$script, $relativeSrc, $destFilename];

        $compiler = $this->app->make('Alberon\Awe\ProcOpen3', [$exe, $args]);
        $compiler->redirectStandardInFromFile($src, 'r');
        $compiler->execute();

        if ($error = stream_get_contents($compiler->getStandardError()))
            throw new Exception($error);

        $content   = stream_get_contents($compiler->getStandardOut());
        $sourcemap = stream_get_contents($compiler->getFD3());

        $compiler->close();

        return [
            'content'   => $content,
            'count'     => 1,
            'action'    => 'compiled',
            'sourcemap' => $this->parseSourceMap($sourcemap),
            'dest'      => $dest,
        ];
    }

    //   _getCss: (src, dest, cb) =>
    //     await @_getFile(src, dest, errTo(cb, defer data))
    //     @_rewriteCss(data, src, dest)
    //     cb(null, data)

    protected function compileSass($src, $dest)
    {
        // Create a temp directory for the output
        $tmpDir = $this->tempdir();

        // Create a config file for Compass
        // (Compass doesn't let us specify all options using the CLI, so we have to
        // generate a config file instead. We could use `sass --compass` instead for
        // some of them, but that doesn't support all the options either.)
        $configFile = $this->tempfile();
        $sourcemap = $this->sourcemaps ? 'true' : 'false';

        $compassConfig = "
            project_path = '{$this->rootPath}'
            cache_path   = '{$this->cachePath}/sass-cache'
            output_style = :expanded

            # Input files
            sass_path        =  '{$this->srcPath}'
            images_path      =  '{$this->srcPath}/img'
            fonts_path       =  '{$this->srcPath}/fonts'
            sprite_load_path << '{$this->srcPath}/_sprites'

            # Output to a temp directory so we can catch any generated files too
            css_path              = '{$tmpDir}'
            generated_images_path = '{$tmpDir}/_generated'
            javascripts_path      = '{$tmpDir}/_generated' # Rarely used but might as well

            # Output a placeholder for URLs - we will rewrite them into relative paths later
            # (Can't use 'relative_assets' because it generates paths like '../../../tmp/tmp-123/img')
            http_path                  = '/AWEDESTROOTPATH'
            http_stylesheets_path      = '/AWEDESTROOTPATH'
            http_images_path           = '/AWEDESTROOTPATH/img'
            http_fonts_path            = '/AWEDESTROOTPATH/fonts'
            http_generated_images_path = '/AWEDESTROOTPATH/_generated'
            http_javascripts_path      = '/AWEDESTROOTPATH/_generated'

            # Disable cache busting URLs (e.g. sample.gif?123456) - it makes unit
            # testing harder! One day I'll add cache busting URLs in a PostCSS filter
            asset_cache_buster :none

            # Disable line number comments - use sourcemaps instead
            line_comments = false
            sourcemap = {$sourcemap}
        ";

        $this->file->put($configFile, $compassConfig);

        // Compile the file using Compass
        $exe = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'ruby_bundle' . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . 'compass';
        $args = ['compile', '--trace', '--config', $configFile, $src];

        $compiler = $this->app->make('fool\executor\ProcOpen', [$exe, $args]);
        $compiler->execute();

        fclose($compiler->getStandardIn());

        if ($error = stream_get_contents($compiler->getStandardError())) {
            $error = preg_replace('/\n?\s*Use --trace for backtrace./', $error);
            // $message = chalk.bold.red("SASS/COMPASS ERROR") + chalk.bold.black(" (#{code})") + "\n#{result}"
            // $file = path.relative(@rootPath, src)
            throw new Exception($error);
        }

        $content = stream_get_contents($compiler->getStandardOut());

        $compiler->close();

        // Copy any extra files that were generated
        $this->copyGeneratedDirectory(
            $tmpDir         . DIRECTORY_SEPARATOR . '_generated',
            $this->destPath . DIRECTORY_SEPARATOR . '_generated'
        );

        // Get the content from the CSS file
        $pathFromRoot = substr($src, strlen($this->srcPath) + 1);
        $outputFile = $tmpDir . DIRECTORY_SEPARATOR . substr($pathFromRoot, 0, -5) . '.css';
        $data = $this->getFile($outputFile, $dest);

        // Get the content from the source map
        if ($this->sourcemaps) {
            $data['sourcemap'] = $this->parseSourceMap(file_get_contents("$outputFile.map"));

            // Make the sources relative to the source directory - we'll change
            // them to be relative to the final destination file later
            // for source, k in data.sourcemap.sources
            //   source = path.resolve(path.dirname(outputFile), source)
            //   data.sourcemap.sources[k] = path.relative(@srcPath, source)

            // @_removeSourceMapComment(data)
        }

        // Rewrite the URLs in the CSS
        // @_rewriteCss(data, src, dest)

        $data['action'] = 'compiled';

        return $data;
    }

    protected function copyGeneratedFileOrDirectory($src, $dest)
    {
        if (is_dir($src))
            $this->copyGeneratedDirectory($src, $dest);
        else
            $this->copyGeneratedFile($src, $dest);
    }

    protected function copyGeneratedFile($src, $dest)
    {
        $data = $this->getFile($src, $dest);
        $data['action'] = 'generated';
        $this->write($data);
    }

    protected function copyGeneratedDirectory($src, $dest)
    {
        if (!is_dir($src))
            return;

        // Get a list of files
        $files = $this->readDirectory($src);

        // Create destination directory
        mkdir($dest, 0777, true);

        // Copy the files
        foreach ($files as $file) {
            $this->copyGeneratedFileOrDirectory(
                $src  . DIRECTORY_SEPARATOR . $file,
                $dest . DIRECTORY_SEPARATOR . $file
            );
        }
    }

    protected function compileFile($src, $dest)
    {
        // Compile CoffeeScript
        if (strtolower(substr($src, -7)) === '.coffee') {
            $dest = substr($dest, 0, -7) . '.js';
            return $this->compileCoffeeScript($src, $dest);
        }

        // Compile Sass
        elseif (strtolower(substr($src, -5)) === '.scss') {
            $dest = substr($dest, 0, -5) . '.css';
            return $this->compileSass($src, $dest);
        }

        // # Import files listed in a YAML file
        // else if src[-9..].toLowerCase() == '.css.yaml' || src[-8..].toLowerCase() == '.js.yaml'
        //   @_compileYamlImports(src, dest.replace(/\.yaml$/i, ''), cb)

        // # Copy CSS and replace URLs
        // else if src[-4..].toLowerCase() == '.css'
        //   @_getCss(src, dest, cb)

        // Copy all other files unchanged
        return $this->getFile($src, $dest);
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

    protected function compileMultipleFiles($files, $dest)
    {
        $content = '';
        $count   = 0;

        foreach ($files as $file) {
            $data = $this->compileFileOrDirectory($file, $dest);

            // Skip files with compile errors
            if (!$data)
                continue;

            // TODO: Any need for this?
            // $data['src'] = $file;

            // TODO: Skip files of a different type (and warn the user)
            // TODO: Concat with sourcemap

            $content .= $data['content'] . "\n";
            $count   += $data['count'];
        }

        // sourcemap = @_parseSourceMap(concat.sourceMap)

        // # Convert absolute paths to relative
        // if sourcemap
        //   for source, k in sourcemap.sources
        //     # It may already be relative (I'm not sure under what circumstances but
        //     # it happens in the unit tests), in which case we can either try to work
        //     # out whether it's absolute or not, or we can convert it to always be
        //     # absolute first - I've chosen the latter. Node.js 0.11 will add
        //     # path.isAbsolute() which will make the former easier in the future.
        //     source = path.resolve(@srcPath, source)
        //     # And now we can convert it from absolute to relative
        //     sourcemap.sources[k] = path.relative(@srcPath, source)

        return [
            'content'   => $content,
            'sourcemap' => null, // TODO
            'count'     => $count,
            'action'    => 'compiled',
            'dest'      => $dest,
        ];
    }

    public function compileFileOrDirectory($src, $dest)
    {
        if (is_dir($src))
            return $this->compileDirectory($src, $dest);
        else
            return $this->compileFile($src, $dest);
    }

    protected function compileDirectory($src, $dest)
    {
        $files = [];

        foreach ($this->readDirectory($src) as $file) {
            if ($file[0] !== '_')
                $files[] = $src . DIRECTORY_SEPARATOR . $file;
        }

        return $this->compileMultipleFiles($files, $dest);
    }


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


    /**
     * Find the relative file system path between two file system paths
     *
     * Source: https://gist.github.com/ohaal/2936041
     *
     * @param  string  $frompath  Path to start from
     * @param  string  $topath    Path we want to end up in
     *
     * @return string             Path leading from $frompath to $topath
     */
    protected function relpath( $frompath, $topath ) {
        $from = explode( DIRECTORY_SEPARATOR, $frompath ); // Folders/File
        $to = explode( DIRECTORY_SEPARATOR, $topath ); // Folders/File
        $relpath = '';

        $i = 0;
        // Find how far the path is the same
        while ( isset($from[$i]) && isset($to[$i]) ) {
            if ( $from[$i] != $to[$i] ) break;
            $i++;
        }
        $j = count( $from ) - 1;
        // Add '..' until the path is the same
        while ( $i <= $j ) {
            if ( !empty($from[$j]) ) $relpath .= '..'.DIRECTORY_SEPARATOR;
            $j--;
        }
        // Go to folder from where it starts differing
        while ( isset($to[$i]) ) {
            if ( !empty($to[$i]) ) $relpath .= $to[$i].DIRECTORY_SEPARATOR;
            $i++;
        }

        // Strip last separator
        return substr($relpath, 0, -1);
    }

    /**
     * Create a temporary directory
     *
     * Based on http://php.net/manual/en/function.tempnam.php#61436
     */
    protected function tempdir($mode=0700)
    {
        $dir = rtrim(sys_get_temp_dir(), '/\\');

        do
        {
            $path = $dir . DIRECTORY_SEPARATOR . 'awe-' . str_pad(mt_rand(0, 9999999999), 10, 0, STR_PAD_RIGHT);
        } while (!@mkdir($path, $mode));

        return $path;
    }

    protected function tempfile()
    {
        return tempnam(sys_get_temp_dir(), 'awe-');
    }
}
