<?php

use Alberon\Awe\Filesystem;
use Mockery as m;

class BuildTest extends TestCase
{
    protected function setUp()
    {
        parent::setUp();

        // Make this a partial so it outputs to the screen if one is missed, to
        // make it easier to debug (vs. a generic BadMethodCall exception)
        $this->output = m::mock('Alberon\Awe\BuildOutput')->makePartial();
    }

    protected function build($root, $config = [])
    {
        // Default config settings
        $config = array_merge([
            'src'                   => 'src/',
            'dest'                  => 'build/',
            'bower'                 => false,
            'autoprefixer'          => false,
            'sourcemaps'            => false,
            'prettyPrintSourcemaps' => true,
            'warningfile'           => false,
        ], $config);

        // Clear the cache and build directories
        $file = new Filesystem;
        $file->deleteDirectory("$root/.awe");
        $file->deleteDirectory("$root/" . $config['dest']);

        // Build it
        $assetGroup = $this->app->make('Alberon\Awe\AssetGroup', [$root, $config, 'output' => $this->output]);
        $assetGroup->build();
    }

    /*--------------------------------------
     Basic copy/compile functionality
    --------------------------------------*/

    public function testCopiesStaticTextFilesUnchanged()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('copied')->once()->with('build/javascript.js', '');
        $this->output->shouldReceive('copied')->once()->with('build/stylesheet.css', '');
        $this->output->shouldReceive('copied')->once()->with('build/unknown.file', '');

        $this->build($root = "{$this->fixtures}/build/copy");

        $this->assertFileEquals("$root/src/javascript.js", "$root/build/javascript.js");
        $this->assertFileEquals("$root/src/stylesheet.css", "$root/build/stylesheet.css");
        $this->assertFileEquals("$root/src/unknown.file", "$root/build/unknown.file");
    }

    public function testCopiesImagesUnchanged()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('copied')->once()->with('build/sample.gif', '');

        $this->build($root = "{$this->fixtures}/build/copy-images");

        $this->assertFileEquals("$root/src/sample.gif", "$root/build/sample.gif");
    }

    public function testCompilesCoffeescriptFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/coffeescript.js', '');

        $this->build($root = "{$this->fixtures}/build/coffeescript");

        $this->assertFileNotExists("$root/build/coffeescript.coffee");
        $this->assertFileEquals("$root/expected/coffeescript.js", "$root/build/coffeescript.js");
    }

    public function testCompilesScssFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/sass.css', '');

        $this->build($root = "{$this->fixtures}/build/sass");

        $this->assertFileNotExists("$root/build/sass.scss");
        $this->assertFileEquals("$root/expected/sass.css", "$root/build/sass.css");
    }

    public function testSkipsFilesStartingWithAnUnderscore()
    {
        $this->output->shouldReceive('created')->once()->with('build/');

        $this->build($root = "{$this->fixtures}/build/underscores");

        $this->assertFileNotExists("$root/build/_ignored.coffee");
        $this->assertFileNotExists("$root/build/_ignored.js");
        $this->assertFileNotExists("$root/build/_vars.scss");
        $this->assertFileNotExists("$root/build/_vars.css");
        $this->assertFileNotExists("$root/build/_file.txt");
        $this->assertFileNotExists("$root/build/file.txt");
        $this->assertFileNotExists("$root/build/_dir");
        $this->assertFileNotExists("$root/build/dir");
    }

    /*--------------------------------------
     Error handling
    --------------------------------------*/

    public function testShowsAnErrorIfSourceDirectoryDoesNotExist()
    {
        $this->output->shouldReceive('error')->once()->with('src/', null, "Source directory doesn't exist");

        $this->build($root = "{$this->fixtures}/build/error-src-missing");

        $this->assertFileNotExists("$root/build");
    }

    public function testShowsAWarningWhenCssIsInvalid()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('warning')->once()->with('src/invalid.css', null, '/Unclosed block/');
        $this->output->shouldReceive('copied')->once()->with('build/invalid.css', '');

        $this->build($root = "{$this->fixtures}/build/css-invalid");

        $this->assertFileEquals("$root/src/invalid.css", "$root/build/invalid.css");
    }

    public function testShowsAnErrorIfAnScssFileIsInvalid()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('error')->once()->with('src/invalid.scss', null, '#SASS/COMPASS ERROR.*(1).*Invalid CSS#s');
        $this->output->shouldReceive('error')->once()->with('src/combined.css/invalid.scss', null, '#SASS/COMPASS ERROR.*(1).*Invalid CSS#s');
        $this->output->shouldReceive('compiled')->once()->with('build/combined.css', '');

        $this->build($root = "{$this->fixtures}/build/error-sass");

        $this->assertFileNotExists("$root/build/invalid.css");
        $this->assertFileEquals("$root/expected/combined.css", "$root/build/combined.css");
    }

    public function testShowsAnErrorIfACoffeescriptFileIsInvalid()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('error')->once()->with('src/invalid.coffee', null, '#COFFEESCRIPT ERROR.*unexpected \(#s');
        $this->output->shouldReceive('error')->once()->with('src/combined.js/invalid.coffee', null, '#COFFEESCRIPT ERROR.*unexpected \(#s');
        $this->output->shouldReceive('compiled')->once()->with('build/combined.js', '');

        $this->build($root = "{$this->fixtures}/build/error-coffeescript");

        $this->assertFileNotExists("$root/build/invalid.coffee");
        $this->assertFileEquals("$root/expected/combined.js", "$root/build/combined.js");
    }

    /*--------------------------------------
     Compass
    --------------------------------------*/

    public function testUsesRelativePathsForCompassUrlHelpers()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/subdir/urls.css', '');

        $this->build($root = "{$this->fixtures}/build/compass-urls");

        $this->assertFileEquals("$root/expected/subdir/urls.css", "$root/build/subdir/urls.css");
    }

    public function testSupportsTheCompassInlineImageHelper()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/inline.css', '');

        $this->build($root = "{$this->fixtures}/build/compass-inline");

        $this->assertFileEquals("$root/expected/inline.css", "$root/build/inline.css");
    }

    public function testSupportsCompassSprites()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/sprite.css', '');
        $this->output->shouldReceive('generated')->once()->with("/^build\/_generated\/icons-[^']+\.png$/", '');

        $this->build($root = "{$this->fixtures}/build/compass-sprites");

        $this->assertFileEquals("$root/expected/sprite.css", "$root/build/sprite.css");
        $this->assertFileEquals("$root/expected/_generated/icons-s71af1c7425.png", "$root/build/_generated/icons-s71af1c7425.png");
    }

    /*--------------------------------------
     Combine directories
    --------------------------------------*/

    public function testCombinesTheContentOfJsDirectories()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/combine.js', '(2 files)');

        $this->build($root = "{$this->fixtures}/build/combine-js");

        $this->assertFileEquals("$root/expected/combine.js", "$root/build/combine.js");
    }

    public function testCombinesTheContentOfCssDirectories()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/combine.css', '(2 files)');

        $this->build($root = "{$this->fixtures}/build/combine-css");

        $this->assertFileEquals("$root/expected/combine.css", "$root/build/combine.css");
    }

    public function testDoesNotCombineTheContentOfOtherDirectories()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('copied')->once()->with('build/combine.other/sample.txt', '');

        $this->build($root = "{$this->fixtures}/build/combine-other");

        $this->assertTrue(is_dir("$root/build/combine.other"), "Expected '$root/build/combine.other' to be a directory");
        $this->assertFileExists("$root/build/combine.other/sample.txt");
    }

    public function testDoesNotCombineTheContentOfNonCssFilesInACssDirectory()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('warning')->once()->with('src/combine.css/ignore.js', '', 'Skipping file (must end with .css/.scss/.css.yaml)');
        $this->output->shouldReceive('warning')->once()->with('src/combine.css/ignore.txt', '', 'Skipping file (must end with .css/.scss/.css.yaml)');
        $this->output->shouldReceive('compiled')->once()->with('build/combine.css', '');

        $this->build($root = "{$this->fixtures}/build/combine-invalid-css");

        $this->assertFileEquals("$root/expected/combine.css", "$root/build/combine.css");
    }

    public function testDoesNotCombineTheContentOfNonJsFilesInAJsDirectory()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('warning')->once()->with('src/combine.js/ignore.css', '', 'Skipping file (must end with .js/.coffee/.js.yaml)');
        $this->output->shouldReceive('warning')->once()->with('src/combine.js/ignore.txt', '', 'Skipping file (must end with .js/.coffee/.js.yaml)');
        $this->output->shouldReceive('compiled')->once()->with('build/combine.js', '');

        $this->build($root = "{$this->fixtures}/build/combine-invalid-js");

        $this->assertFileEquals("$root/expected/combine.js", "$root/build/combine.js");
    }

    /*--------------------------------------
     YAML imports
    --------------------------------------*/

    public function testImportsJavascriptFilesFromYaml()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/import.js', '(2 files)');

        $this->build($root = "{$this->fixtures}/build/yaml-js");

        $this->assertFileNotExists("$root/build/import.js.yaml");
        $this->assertFileEquals("$root/expected/import.js", "$root/build/import.js");
    }

    public function testImportsCssFilesFromYaml()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/import.css', '(2 files)');

        $this->build($root = "{$this->fixtures}/build/yaml-css");

        $this->assertFileNotExists("$root/build/import.css.yaml");
        $this->assertFileEquals("$root/expected/import.css", "$root/build/import.css");
    }

    public function testDoesNotParseOtherYamlFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('copied')->once()->with('build/import.txt.yaml', '');

        $this->build($root = "{$this->fixtures}/build/yaml-other");

        $this->assertFileNotExists("$root/build/import.txt");
        $this->assertFileEquals("$root/src/import.txt.yaml", "$root/build/import.txt.yaml");
    }

    public function testAllowsImportsOutsideTheSourceDirectoryInYamlFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/import.js', '(3 files)');

        $this->build($root = "{$this->fixtures}/build/yaml-outside");

        $this->assertFileEquals("$root/expected/import.js", "$root/build/import.js");
    }

    public function testImportsYamlFilesNestedInsideOtherYamlFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/import.js', '');

        $this->build($root = "{$this->fixtures}/build/yaml-nested");

        $this->assertFileEquals("$root/expected/import.js", "$root/build/import.js");
    }

    public function testCombinesFilesInADirectoryListedInAYamlFile()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/import.js', '(4 files)');

        $this->build($root = "{$this->fixtures}/build/yaml-combine");

        $this->assertFileEquals("$root/expected/import.js", "$root/build/import.js");
    }

    public function testShowsAnErrorIfAnImportedFileCannotBeFound()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('warning')->once()->with('src/import-error.js.yaml', '', "'src/missing.js' doesn't exist");
        $this->output->shouldReceive('compiled')->once()->with('build/import-error.js', '');

        $this->build($root = "{$this->fixtures}/build/yaml-missing");

        $this->assertFileEquals("$root/expected/import-error.js", "$root/build/import-error.js");
    }

    /*--------------------------------------
     Autoprefixer
    --------------------------------------*/

    public function testAddsCrossBrowserPrefixesToCssFilesWithAutoprefixer()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('copied')->once()->with('build/autoprefixer.css', '');

        $this->build($root = "{$this->fixtures}/build/autoprefixer-css", ['autoprefixer' => true]);

        $this->assertFileEquals("$root/expected/autoprefixer.css", "$root/build/autoprefixer.css");
    }

    public function testAddsCrossBrowserPrefixesToScssFilesWithAutoprefixer()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/autoprefixer.css', '');

        $this->build($root = "{$this->fixtures}/build/autoprefixer-scss", ['autoprefixer' => true]);

        $this->assertFileEquals("$root/expected/autoprefixer.css", "$root/build/autoprefixer.css");
    }

    public function testDoesNotAddCrossBrowserPrefixesToNonCssFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('copied')->once()->with('build/autoprefixer.txt', '');

        $this->build($root = "{$this->fixtures}/build/autoprefixer-other", ['autoprefixer' => true]);

        $this->assertFileEquals("$root/src/autoprefixer.txt", "$root/build/autoprefixer.txt");
    }

    /*--------------------------------------
     Bower
    --------------------------------------*/

    public function testCreatesASymlinkToBowerDirectory()
    {
        $this->output->shouldReceive('created')->once()->with('build/');

        $this->build($root = "{$this->fixtures}/build/bower-symlink", ['bower' => 'bower_components/']);

        $this->assertFileExists("$root/build/_bower");
        $this->assertTrue(is_link("$root/build/_bower"), "Expected '$root/build/_bower' to be a symlink");
        $this->assertTrue(is_dir("$root/build/_bower"), "Expected '$root/build/_bower' to be a directory");
        $this->assertFileExists("$root/build/_bower/bower.txt");
    }

    public function testShowsAWarningAndDoesNotCreateASymlinkIfBowerDirectoryDoesNotExist()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('warning')->once()->with('bower_components/', '', "Bower directory doesn't exist");

        $this->build($root = "{$this->fixtures}/build/bower-missing", ['bower' => 'bower_components/']);

        $this->assertFileNotExists("$root/build/_bower");
    }

    public function testDoesNotCreateASymlinkIfBowerOptionIsFalse()
    {
        $this->output->shouldReceive('created')->once()->with('build/');

        $this->build($root = "{$this->fixtures}/build/bower-disabled", ['bower' => false]);

        $this->assertFileNotExists("$root/build/_bower");
    }

    /*--------------------------------------
     URL rewriting
    --------------------------------------*/
    // For full tests see javascript/test/UrlRewriter.coffee - this just checks they are applied correctly

    public function testRewritesRelativeUrlsInDirectoryCombinedCssFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/combine.css', '');
        $this->output->shouldReceive('copied')->once()->with('build/sample.gif', '');

        $this->build($root = "{$this->fixtures}/build/rewrite-combined", ['bower' => 'bower_components/']);

        $this->assertFileEquals("$root/expected/combine.css", "$root/build/combine.css");
    }

    public function testRewritesRelativeUrlsInBowerFilesUsingTheSymlink()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/subdir/bower.css', '');

        $this->build($root = "{$this->fixtures}/build/rewrite-bower", ['bower' => 'bower_components/']);

        $this->assertFileEquals("$root/expected/subdir/bower.css", "$root/build/subdir/bower.css");
    }

    public function testRewritesRelativeUrlsInToOutsideFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/outside.css', '');

        $this->build($root = "{$this->fixtures}/build/rewrite-outside");

        $this->assertFileEquals("$root/expected/outside.css", "$root/build/outside.css");
    }

    public function testRewritesRelativeUrlsYamlImportedCssFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/import.css', '');
        $this->output->shouldReceive('copied')->once()->with('build/sample.gif', '');

        $this->build($root = "{$this->fixtures}/build/rewrite-yaml", ['bower' => 'bower_components/']);

        $this->assertFileEquals("$root/expected/import.css", "$root/build/import.css");
    }

    public function testWarnsAboutInvalidRelativeUrlsInCssButDoesNotChangeThem()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('warning')->once()->with('src/invalid-url.css', null, "/Invalid file path: 'invalid.gif'/");
        $this->output->shouldReceive('copied')->once()->with('build/invalid-url.css', '');

        $this->build($root = "{$this->fixtures}/build/rewrite-invalid");

        $this->assertFileEquals("$root/expected/invalid-url.css", "$root/build/invalid-url.css");
    }

    /*--------------------------------------
     Source maps
    --------------------------------------*/

    public function testDoesNotCreateMapFileIfSourceMapsAreDisabled()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/coffeescript.js', '');

        $this->build($root = "{$this->fixtures}/build/sourcemap-disabled", ['sourcemaps' => false]);

        $this->assertFileExists("$root/build/coffeescript.js");
        $this->assertFileNotExists("$root/build/coffeescript.js.map");
    }

    public function testCreatesSourceMapsForCoffeescript()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/coffeescript.js', '');

        $this->build($root = "{$this->fixtures}/build/sourcemap-coffeescript", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/coffeescript.js", "$root/build/coffeescript.js");
        $this->assertFileEquals("$root/expected/coffeescript.js.map", "$root/build/coffeescript.js.map");
    }

    public function testCreatesSourceMapsForAutoprefixedCss()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('copied')->once()->with('build/styles.css', '');

        $this->build($root = "{$this->fixtures}/build/sourcemap-css-autoprefixer", ['sourcemaps' => true, 'autoprefixer' => true]);

        $this->assertFileEquals("$root/expected/styles.css", "$root/build/styles.css");
        $this->assertFileEquals("$root/expected/styles.css.map", "$root/build/styles.css.map");
    }

    public function testCreatesSourceMapsForScssFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/sass.css', '');

        $this->build($root = "{$this->fixtures}/build/sourcemap-sass", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/sass.css", "$root/build/sass.css");
        $this->assertFileEquals("$root/expected/sass.css.map", "$root/build/sass.css.map");
    }

    public function testCreatesSourceMapsForScssFilesWithSprites()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('generated')->once()->with('#build/_generated/icons-.*\.png#', '');
        $this->output->shouldReceive('compiled')->once()->with('build/sprite.css', '');

        $this->build($root = "{$this->fixtures}/build/sourcemap-compass-sprites", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/sprite.css", "$root/build/sprite.css");
        $this->assertFileEquals("$root/expected/sprite.css.map", "$root/build/sprite.css.map");
    }

    public function testCreatesSourceMapsForCombinedJavascriptDirectories()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/combine.js', '(2 files)');

        $this->build($root = "{$this->fixtures}/build/sourcemap-combine-js", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/combine.js", "$root/build/combine.js");
        $this->assertFileEquals("$root/expected/combine.js.map", "$root/build/combine.js.map");
    }

    public function testCreatesSourceMapsForCombinedCssDirectories()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/combine.css', '(2 files)');

        $this->build($root = "{$this->fixtures}/build/sourcemap-combine-css", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/combine.css", "$root/build/combine.css");
        $this->assertFileEquals("$root/expected/combine.css.map", "$root/build/combine.css.map");
    }

    public function testCreatesSourceMapsForYamlImports()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/import.js', '(4 files)');

        $this->build($root = "{$this->fixtures}/build/sourcemap-yaml-combine", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/import.js", "$root/build/import.js");
        $this->assertFileEquals("$root/expected/import.js.map", "$root/build/import.js.map");
    }

    public function testCreatesSourceMapsForEmptyCssFiles()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/dir.css', '');

        $this->build($root = "{$this->fixtures}/build/sourcemap-combine-empty", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/dir.css", "$root/build/dir.css");
        $this->assertFileEquals("$root/expected/dir.css.map", "$root/build/dir.css.map");
    }

    public function testCreatesSourceMapForEmptyScssFile()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/empty.css', '');

        $this->build($root = "{$this->fixtures}/build/sourcemap-empty-sass", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/empty.css", "$root/build/empty.css");
        $this->assertFileEquals("$root/expected/empty.css.map", "$root/build/empty.css.map");
    }

    /*--------------------------------------
     Miscellaneous
    --------------------------------------*/

    public function testPutsCacheFilesInHiddenDirectoryAndCreatesGitignoreFile()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('compiled')->once()->with('build/styles.css', '');

        $this->build($root = "{$this->fixtures}/build/cache");

        $this->assertFileExists("$root/.awe");
        $this->assertFileExists("$root/.awe/sass-cache");
        $this->assertFileEquals("$root/expected/.gitignore", "$root/.awe/.gitignore");
    }

    public function testCreatesAFileWarningUsersNotToEditFilesInTheBuildDirectory()
    {
        $this->output->shouldReceive('created')->once()->with('build/');
        $this->output->shouldReceive('generated')->once()->with('build/_DO_NOT_EDIT.txt', '');

        $this->build($root = "{$this->fixtures}/build/warning-file", ['warningfile' => true]);

        $this->assertFileEquals("$root/expected/_DO_NOT_EDIT.txt", "$root/build/_DO_NOT_EDIT.txt");
    }
}
