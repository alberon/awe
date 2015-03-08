<?php
namespace Alberon\Awe;

use Exception;
use Illuminate\Contracts\Filesystem\FileNotFoundException;
use Kwf_SourceMaps_SourceMap as SourceMap;

class AssetGroup
{
    protected $app;
    protected $file;
    protected $output;
    protected $temp;
    protected $yamlMap;

    protected $autoprefixer;
    protected $bower;
    protected $bowerLink;
    protected $bowerSrc;
    protected $bundlePath;
    protected $destPath;
    protected $prettyPrintSourcemaps;
    protected $rootPath;
    protected $sourcemaps;
    protected $srcPath;
    protected $warningFile;

    protected $cssExtensions = ['.css', '.scss', '.css.yaml'];
    protected $jsExtensions  = ['.js', '.coffee', '.js.yaml'];

    public function __construct($rootPath, $config, App $app, Filesystem $file, Temp $temp, BuildOutput $output, YamlMap $yamlMap)
    {
        // Dependencies
        $this->app     = $app;
        $this->file    = $file;
        $this->output  = $output;
        $this->temp    = $temp;
        $this->yamlMap = $yamlMap;

        // Settings
        $this->rootPath              = rtrim($rootPath, '/\\');
        $this->autoprefixer          = $config['autoprefixer'];
        $this->bower                 = rtrim($config['bower'], '/\\');
        $this->sourcemaps            = $config['sourcemaps'];
        $this->prettyPrintSourcemaps = isset($config['prettyPrintSourcemaps']) ? (bool) $config['prettyPrintSourcemaps'] : false;

        // Normalise paths
        $this->srcPath  = $this->rootPath . DIRECTORY_SEPARATOR . rtrim($config['src'], '/\\');
        $this->destPath = $this->rootPath . DIRECTORY_SEPARATOR . rtrim($config['dest'], '/\\');

        if ($config['warningfile'])
            $this->warningFile = $this->destPath . '/_DO_NOT_EDIT.txt';
        else
            $this->warningFile = false;

        // Generated paths
        if ($this->bower) {
            $this->bowerLink = $this->destPath . DIRECTORY_SEPARATOR . '_bower';
            $this->bowerSrc  = $this->rootPath . DIRECTORY_SEPARATOR . $this->bower;
        }

        // Script paths
        $this->bundlePath = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'ruby_bundle';
    }

    public function build()
    {
        // Check if the source directory exists
        if (!$this->file->exists($this->srcPath)) {
            $path = $this->relDirPath($this->rootPath, $this->srcPath);
            $this->output->error($path, null, "Source directory doesn't exist");
            return;
        }

        // Create cache directory
        $this->cachePath = $this->rootPath . DIRECTORY_SEPARATOR . '.awe';
        $ignoreFile = $this->cachePath . DIRECTORY_SEPARATOR . '.gitignore';

        if (!$this->file->exists($this->cachePath))
            $this->file->makeDirectory($this->cachePath, 0777, true);

        $this->file->put($ignoreFile, "# Automatically generated by Awe - ignore all files\n*\n");

        // Need to know if the destination already exists for the output message
        $destExists = $this->file->exists($this->destPath);

        // Create/empty the destination
        $path = $this->relDirPath($this->rootPath, $this->destPath);
        if ($destExists) {
            $this->file->cleanDirectory($this->destPath);
            $this->output->emptied($path);
        } else {
            $this->file->makeDirectory($this->destPath, 0777, true);
            $this->output->created($path);
        }

        // Create a symlink to the bower_components directory
        if ($this->bower && !$this->file->exists($this->bowerSrc)) {
            $path = str_finish($this->bower, DIRECTORY_SEPARATOR);
            $this->output->warning($path, '', "Bower directory doesn't exist");
            $this->bower     = false;
            $this->bowerLink = null;
            $this->bowerSrc  = null;
        }

        if ($this->bower)
            $this->createSymlink($this->bowerSrc, $this->bowerLink);

        // Create a file warning people not to edit the compiled files
        if ($this->warningFile) {
            $content = $this->renderTemplate('_DO_NOT_EDIT', [
                'source' => $this->relPath($this->destPath, $this->srcPath),
            ]);

            $this->write([
                'content'   => $content,
                'sourcemap' => null,
                'count'     => 1,
                'action'    => 'generated',
                'dest'      => $this->warningFile,
            ]);
        }

        // Compile the directory
        $this->buildRegularDirectory($this->srcPath, $this->destPath);

        // Clean up temp files
        $this->temp->cleanAll();
    }

    protected function createSymlink($target, $link)
    {
        $target = $this->relPath(dirname($link), $target);
        symlink($target, $link);
    }

    protected function addSourceMapComment(&$data)
    {
        $file = strtolower($data['dest']);
        $map = basename($data['dest']) . '.map';

        if (ends_with($file, '.js'))
            $data['content'] .= "\n//# sourceMappingURL={$map}\n";
        elseif (ends_with($file, '.css'))
            $data['content'] .= "\n/*# sourceMappingURL={$map} */\n";
        else
            throw new Exception("Don't know how to add a source map comment to '{$data['dest']}'");
    }

    protected function removeSourceMapComment(&$data)
    {
        // This is for when an external library (PostCSS, Sass) adds a comment we
        // don't want (because we want to combine files and then add the comment at
        // the very end)
        $data['content'] = preg_replace('/[\r\n]*\/\*# sourceMappingURL=[^ ]+ \*\/[\r\n]*$/', "\n", $data['content']);
    }

    protected function parseSourceMap($sourcemap)
    {
        return json_decode($sourcemap);
    }

    protected function inlineSourceMapContent(&$data)
    {
        $data['sourcemap']->sourcesContent = array_map(function($file)
        {
            $content = $this->file->get($this->srcPath . DIRECTORY_SEPARATOR . $file);
            $content = str_replace("\r\n", "\n", $content); // Firefox doesn't like Windows line endings
            return $content;
        }, $data['sourcemap']->sources);
    }

    protected function rewriteSourceMapFilenames(&$data)
    {
        foreach ($data['sourcemap']->sources as $i => &$source)
        {
            $sourcePath = $this->resolvePath($this->srcPath, $source);

            // Compass sometimes adds its own internal files to the sourcemap which
            // results in ugly ../../../ paths - rewrite them to something readable.
            // Note: This has to be done *after* inlineSourceMapContent() is called.
            if (starts_with($sourcePath, $this->bundlePath))
                $source = '_awe/ruby_bundle' . substr($sourcePath, strlen($this->bundlePath));
        }
    }

    protected function write($data)
    {
        if (!$data || $data['content'] === null)
            return;

        // Write source map
        if ($this->sourcemaps && !empty($data['sourcemap']))
            $this->writeSourcemap($data);

        // Write file
        $this->file->put($data['dest'], $data['content']);

        // Output message on screen
        if ($action = $data['action']) {
            $path = $this->relPath($this->rootPath, $data['dest']);
            $notes = ($data['count'] > 1 ? "({$data['count']} files)" : '');
            $this->output->$action($path, $notes);
        }
    }

    protected function writeSourcemap(&$data)
    {
        // Put all source content inline, in case the source is outside the document root
        $this->inlineSourceMapContent($data);

        // Set source root path so all filenames are relative to the source directory
        $data['sourcemap']->sourceRoot = $this->relPath(dirname($data['dest']), $this->srcPath);

        // Rewrite filenames
        $this->rewriteSourceMapFilenames($data);

        // Add source mapping comment to the file
        $this->addSourceMapComment($data);

        // Put the array in alphabetical order to facilitate unit testing
        $sourcemap = (array) $data['sourcemap'];
        ksort($sourcemap);

        // Convert to JSON
        $pp = $this->prettyPrintSourcemaps ? JSON_PRETTY_PRINT : 0;
        $json = json_encode($sourcemap, JSON_UNESCAPED_SLASHES | $pp);

        // Save file
        $this->file->put($data['dest'] . '.map', $json);
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

        if (ends_with($file, '.css')) {

            $data = $this->compileDirectory($src, $dest, $this->cssExtensions);
            $this->write($data);

        } elseif (ends_with($file, '.js')) {

            $data = $this->compileDirectory($src, $dest, $this->jsExtensions);
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
        if (!$this->file->exists($dest))
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

    protected function getFile($src, $dest, $action = 'copied')
    {
        return [
            'content'   => $this->file->get($src),
            'sourcemap' => null,
            'count'     => 1,
            'action'    => $action,
            'dest'      => $dest,
        ];
    }

    protected function compileCoffeeScript($src, $dest)
    {
        $script       = dirname(__DIR__) . '/javascript/compile-coffeescript.coffee';
        $relativeSrc  = $this->relPath($this->srcPath, $src);
        $destFilename = basename($dest);

        $exe  = dirname(__DIR__) . '/node_modules/.bin/coffee';
        $args = [$script, $relativeSrc, $destFilename];

        $compiler = $this->app->make('Alberon\Awe\ProcOpen', [$exe, $args]);
        $compiler->redirectStandardInFromFile($src, 'r');
        $compiler->addPipe(3, 'w');
        $compiler->execute();

        $content   = stream_get_contents($compiler->getStandardOut());
        $error     = stream_get_contents($compiler->getStandardError());
        $sourcemap = stream_get_contents($compiler->getPipe(3));

        $compiler->close();

        if ($error) {
            $message = "<error>COFFEESCRIPT ERROR</error>\n{$error}";
            $path = $this->relPath($this->rootPath, $src);
            $this->output->error($path, null, $message);
            return;
        }

        return [
            'content'   => $content,
            'sourcemap' => $this->parseSourceMap($sourcemap),
            'count'     => 1,
            'action'    => 'compiled',
            'dest'      => $dest,
        ];
    }

    protected function compileSass($src, $dest)
    {
        // Create a temp directory for the output
        $tmpDir = $this->temp->dir();

        // Create a config file for Compass
        // (Compass doesn't let us specify all options using the CLI, so we have to
        // generate a config file instead. We could use `sass --compass` instead for
        // some of them, but that doesn't support all the options either.)
        $configFile = $this->temp->file();

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
            sourcemap = true
        ";

        $this->file->put($configFile, $compassConfig);

        // Compile the file using Compass
        $exe = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'ruby_bundle' . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . 'compass';
        $args = ['compile', '--trace', '--config', $configFile, $src];

        $compiler = $this->app->make('fool\executor\ProcOpen', [$exe, $args]);
        $compiler->redirectStandardErrorToStandardOut();
        $compiler->execute();

        fclose($compiler->getStandardIn());

        $content = stream_get_contents($compiler->getStandardOut());
        $code = $compiler->close();

        if ($code > 0) {
            $error = preg_replace('/\n?\s*Use --trace for backtrace./', '', $content);
            $message = "<error>SASS/COMPASS ERROR</error> <grey>({$code})</grey>\n{$error}";
            $path = $this->relPath($this->rootPath, $src);
            $this->output->error($path, null, $message);
            return;
        }

        $compiler->close();

        // Copy any extra files that were generated
        $this->copyGeneratedDirectory(
            $tmpDir         . DIRECTORY_SEPARATOR . '_generated',
            $this->destPath . DIRECTORY_SEPARATOR . '_generated'
        );

        // Get the content from the CSS file
        $pathFromRoot = substr($src, strlen($this->srcPath) + 1);
        $outputFile = $tmpDir . DIRECTORY_SEPARATOR . substr($pathFromRoot, 0, -5) . '.css';
        $data = $this->getFile($outputFile, $dest, 'compiled');

        // Get the content from the source map
        $data['sourcemap'] = $this->parseSourceMap(file_get_contents("$outputFile.map"));

        // Make the sources relative to the source directory - we'll change
        // them to be relative to the final destination file later
        if (isset($data['sourcemap']->sources)) {
            foreach ($data['sourcemap']->sources as &$source) {
                $source = realpath(dirname($outputFile) . DIRECTORY_SEPARATOR . $source);
                $source = $this->relPath($this->srcPath, $source);
            }
        }

        $this->removeSourceMapComment($data);

        // Rewrite the URLs in the CSS
        $data = $this->rewriteCss($data, $src, $dest);

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
        $data = $this->getFile($src, $dest, 'generated');
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
        $file = strtolower($src);

        if (ends_with($file, '.coffee')) {

            // Compile CoffeeScript
            $dest = substr($dest, 0, -7) . '.js';
            return $this->compileCoffeeScript($src, $dest);

        } elseif (ends_with($file, '.scss')) {

            // Compile Sass
            $dest = substr($dest, 0, -5) . '.css';
            return $this->compileSass($src, $dest);

        } elseif (ends_with($file, '.css.yaml')) {

            // Import files listed in a CSS YAML file
            $dest = substr($dest, 0, -5);
            return $this->compileYamlImports($src, $dest, $this->cssExtensions);

        } elseif (ends_with($file, '.js.yaml')) {

            // Import files listed in a JS YAML file
            $dest = substr($dest, 0, -5);
            return $this->compileYamlImports($src, $dest, $this->jsExtensions);

        } elseif (ends_with($file, '.css')) {

            // Copy CSS, replace relative URLs and run Autoprefixer
            $data = $this->getFile($src, $dest);
            return $this->rewriteCss($data, $src, $dest);

        } else {

            // Copy all other files unchanged
            return $this->getFile($src, $dest);

        }
    }

    protected function rewriteCss($data, $src, $dest)
    {
        $script       = dirname(__DIR__) . '/javascript/rewrite-css.coffee';
        $relativeSrc  = $this->relPath($this->srcPath, $src);
        $destFilename = basename($dest);

        // PostCSS expects input sourcemap paths to be relative to the new source file
        $srcDir = dirname($src);
        if (isset($data['sourcemap']->sources)) {
            foreach ($data['sourcemap']->sources as &$source) {
                $source = $this->relPath($srcDir, $this->srcPath . DIRECTORY_SEPARATOR . $source);
            }
        }

        $exe  = dirname(__DIR__) . '/node_modules/.bin/coffee';
        $args = [
            $script,
            $this->rootPath,
            $this->srcPath,
            $src,
            $this->destPath,
            $dest,
            $this->bowerSrc,
            $this->bowerLink,
            $this->autoprefixer ? 1 : 0,
        ];

        $compiler = $this->app->make('Alberon\Awe\ProcOpen', [$exe, $args]);
        $compiler->addPipe(3, 'r');
        $compiler->addPipe(4, 'w');
        $compiler->execute();

        $stdin = $compiler->getStandardIn();
        fwrite($stdin, $data['content']);
        fclose($stdin);

        $mapin = $compiler->getPipe(3);
        fwrite($mapin, json_encode($data['sourcemap'], JSON_UNESCAPED_SLASHES));
        fclose($mapin);

        $content   = stream_get_contents($compiler->getStandardOut());
        $error     = stream_get_contents($compiler->getStandardError());
        $sourcemap = stream_get_contents($compiler->getPipe(4));

        $compiler->close();

        if ($error) {
            $path = $this->relPath($this->rootPath, $src);
            $this->output->warning($path, null, $error);
            return $data;
        }

        $data['content']   = $content;
        $data['sourcemap'] = $this->parseSourceMap($sourcemap);

        $this->removeSourceMapComment($data);

        return $data;
    }

    protected function compileMultipleFiles($files, $dest, $allowedExtensions)
    {
        $map = SourceMap::createEmptyMap('');
        $map->setFile(basename($dest));
        $count = 0;

        foreach ($files as $file) {
            $data = $this->compileFileOrDirectory($file, $dest, $allowedExtensions);

            // Skip files with compile errors
            if (!$data)
                continue;

            if ($data['sourcemap']) {
                // Fix for error "line count in mapping doesn't match file"
                $lineCountInSourcemap = substr_count($data['sourcemap']->mappings, ';');
                $lineCountInContent   = substr_count($data['content'], "\n");
                $data['sourcemap']->mappings .= str_repeat(';', $lineCountInContent - $lineCountInSourcemap);

                $fileMap = new SourceMap($data['sourcemap'], $data['content']);
            } else {
                // Have to trim new lines from the end of the input files
                // because otherwise the source map generator either complains
                // that the number of lines in the map doesn't match the number
                // of lines in the input file, or it generates an invalid
                // mapping by missing out a semi-colon
                $data['content'] = rtrim($data['content'], "\r\n");

                $path = $this->relPath($this->srcPath, $file);
                $fileMap = SourceMap::createEmptyMap($data['content']);
                foreach (explode("\n", $data['content']) as $i => $line) {
                    $fileMap->addMapping($i + 1, 0, $i + 1, 0, $path);
                }
            }

            $map->concat($fileMap);
            $count += $data['count'];
        }

        $sourcemap = $map->getMapContentsData(false);
        unset($sourcemap->{'_x_org_koala-framework_last'});

        $content = $map->getFileContents();

        return [
            'content'   => $content,
            'sourcemap' => $sourcemap,
            'count'     => $count,
            'action'    => 'compiled',
            'dest'      => $dest,
        ];
    }

    public function compileFileOrDirectory($src, $dest, $allowedExtensions)
    {
        $file = strtolower($src);

        if (is_dir($src)) {
            return $this->compileDirectory($src, $dest, $allowedExtensions);
        } elseif (ends_with($src, $allowedExtensions)) {
            return $this->compileFile($src, $dest);
        } else {
            $path = $this->relPath($this->rootPath, $src);
            $this->output->warning($path, null, 'Skipping file (must end with ' . implode('/', $allowedExtensions) . ')');
            return;
        }
    }

    protected function compileDirectory($src, $dest, $allowedExtensions)
    {
        $files = [];

        foreach ($this->readDirectory($src) as $file) {
            if ($file[0] !== '_')
                $files[] = $src . DIRECTORY_SEPARATOR . $file;
        }

        return $this->compileMultipleFiles($files, $dest, $allowedExtensions);
    }

    protected function compileYamlImports($yamlFile, $dest, $allowedExtensions)
    {
        $files = $this->yamlMap->load($yamlFile, $this->bowerSrc);

        // Make sure all files actually exist
        foreach ($files as $i => $file) {
            if (!$this->file->exists($file)) {
                $yamlPath = $this->relPath($this->rootPath, $yamlFile);
                $filePath = $this->relPath($this->rootPath, $file);
                $this->output->warning($yamlPath, '', "'$filePath' doesn't exist");
                unset($files[$i]);
            }
        }

        return $this->compileMultipleFiles($files, $dest, $allowedExtensions);
    }

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
    protected function relPath( $frompath, $topath ) {
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

    protected function relDirPath($frompath, $topath)
    {
        return str_finish($this->relPath($frompath, $topath), DIRECTORY_SEPARATOR);
    }

    /**
     * Normalize path
     *
     * http://stackoverflow.com/a/20545583/167815
     *
     * @param   string  $path
     * @param   string  $separator
     * @return  string  normalized path
     */
    protected function normalizePath($path, $separator = '\\/')
    {
        // Remove any kind of funky unicode whitespace
        $normalized = preg_replace('#\p{C}+|^\./#u', '', $path);

        // Path remove self referring paths ("/./").
        $normalized = preg_replace('#/\.(?=/)|^\./|\./$#', '', $normalized);

        // Regex for resolving relative paths
        $regex = '#\/*[^/\.]+/\.\.#Uu';

        while (preg_match($regex, $normalized)) {
            $normalized = preg_replace($regex, '', $normalized);
        }

        if (preg_match('#/\.{2}|\.{2}/#', $normalized)) {
            throw new LogicException('Path is outside of the defined root, path: [' . $path . '], resolved: [' . $normalized . ']');
        }

        return rtrim($normalized, $separator);
    }

    protected function resolvePath($dir, $file)
    {
        return $this->normalizePath($dir . DIRECTORY_SEPARATOR . $file);
    }

    protected function renderTemplate($__template, $__vars)
    {
        extract($__vars);
        ob_start();
        require dirname(__DIR__) . DIRECTORY_SEPARATOR . 'templates' . DIRECTORY_SEPARATOR . $__template . '.php';
        return ob_get_clean();
    }
}
