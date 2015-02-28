<?php

use Alberon\Awe\Filesystem;

class BuildTest extends TestCase
{
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

        // # Check all the listed files exist - this is partly to double-check the
        // # directory structure, and partly a way to document it
        // if files
        //   for file in files
        //     expect("#{root}/#{file}").to.be.a.path('TEST SETUP ERROR')

        // Clear the cache and build directories
        $file = new Filesystem;
        $file->deleteDirectory("$root/.awe");
        $file->deleteDirectory("$root/" . $config['dest']);

        // # Disable output
        // output.disable()

        // # Insert a blank line to separate build output from the previous test (if the line above is commented out for testing)
        // output.line()
        // output.building()

        // # Start counting warnings & errors
        // output.resetCounters()

        // Build it
        $assetGroup = $this->app->make('Alberon\Awe\AssetGroup', [$root, $config]);
        $assetGroup->build();

        // (new AssetGroup(root, config)).build (err, result) ->
        //   # Insert another blank line to separate build output from the test results
        //   output.finished()
        //   output.line()

        //     # Check for error/warning messages
        //     expect(output.counters.error || 0).to.equal(errors || 0, "Expected #{errors || 0} error(s)")
        //     expect(output.counters.warning || 0).to.equal(warnings || 0, "Expected #{warnings || 0} warning(s)")
    }

    /*--------------------------------------
     Basic copy/compile functionality
    --------------------------------------*/

    public function testCopiesStaticTextFilesUnchanged()
    {
        $this->build($root = "{$this->fixtures}/build/copy");

        $this->assertFileEquals("$root/src/javascript.js", "$root/build/javascript.js");
        $this->assertFileEquals("$root/src/stylesheet.css", "$root/build/stylesheet.css");
        $this->assertFileEquals("$root/src/unknown.file", "$root/build/unknown.file");
    }

    public function testCopiesImagesUnchanged()
    {
        $this->build($root = "{$this->fixtures}/build/copy-images");

        $this->assertFileEquals("$root/src/sample.gif", "$root/build/sample.gif");
    }

    public function testCompilesCoffeescriptFiles()
    {
        $this->build($root = "{$this->fixtures}/build/coffeescript");

        $this->assertFileNotExists("$root/build/coffeescript.coffee");
        $this->assertFileEquals("$root/expected/coffeescript.js", "$root/build/coffeescript.js");
    }

    public function testCompilesScssFiles()
    {
        $this->build($root = "{$this->fixtures}/build/sass");

        $this->assertFileNotExists("$root/build/sass.scss");
        $this->assertFileEquals("$root/expected/sass.css", "$root/build/sass.css");
    }

    public function testSkipsFilesStartingWithAnUnderscore()
    {
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

    // it 'should display a warning when CSS is invalid', build
    //   root: "#{fixtures}/build/css-invalid"
    //   files: [
    //     'src/invalid.css'
    //   ]
    //   warnings: 1


    /*--------------------------------------
     Error handling
    --------------------------------------*/

    // it 'should show an error if src/ does not exist', build
    //   root: "#{fixtures}/build/error-src"
    //   errors: 1


    // it 'should handle errors in Sass files', build
    //   root: "#{fixtures}/build/error-sass"
    //   files: [
    //     'src/invalid.scss'
    //     'src/combined.css/invalid.scss'
    //   ]
    //   errors: 2


    // it 'should handle errors in CoffeeScript files', build
    //   root: "#{fixtures}/build/error-coffeescript"
    //   files: [
    //     'src/invalid.coffee'
    //     'src/combined.js/invalid.coffee'
    //   ]
    //   errors: 2


    /*--------------------------------------
     Compass
    --------------------------------------*/

    // public function testUsesRelativePathsForCompassUrlHelpers()
    // {
    //     $this->build($root = "{$this->fixtures}/build/compass-urls");

    //     $this->assertFileEquals("$root/expected/subdir/urls.css", "$root/build/subdir/urls.css");
    // }

    public function testSupportsTheCompassInlineImageHelper()
    {
        $this->build($root = "{$this->fixtures}/build/compass-inline");

        $this->assertFileEquals("$root/expected/inline.css", "$root/build/inline.css");
    }

    // public function testSupportsCompassSprites()
    // {
    //     $this->build($root = "{$this->fixtures}/build/compass-sprites");

    //     $this->assertFileEquals("$root/expected/sprite.css", "$root/build/sprite.css");

    //     preg_match("/background-image: url\('_generated\/(icons-[^']+\.png)'\);/)", file_get_contents("$root/build/sprite.css"), $matches);
    //     $this->assertFileExists("$root/build/_generated/" . $matches[1]);
    // }

    // #----------------------------------------
    // # Combine directories
    // #----------------------------------------

    public function testCombinesTheContentOfJsDirectories()
    {
        $this->build($root = "{$this->fixtures}/build/combine-js");

        $this->assertFileEquals("$root/expected/combine.js", "$root/build/combine.js");
    }

    public function testCombinesTheContentOfCssDirectories()
    {
        $this->build($root = "{$this->fixtures}/build/combine-css");

        $this->assertFileEquals("$root/expected/combine.css", "$root/build/combine.css");
    }

    public function testDoesntCombineTheContentOfOtherDirectories()
    {
        $this->build($root = "{$this->fixtures}/build/combine-other");

        $this->assertTrue(is_dir("$root/build/combine.other"), "Expected '$root/build/combine.other' to be a directory");
        $this->assertFileExists("$root/build/combine.other/sample.txt");
    }

    // public function testDoesntCombineTheContentOfNonCssFilesInACssDirectory()
    // {
    //     $this->build($root = "{$this->fixtures}/build/combine-invalid");

    //     $this->assertFileEquals("$root/expected/combine.css", "$root/build/combine.css");
    // }

    // #----------------------------------------
    // # YAML imports
    // #----------------------------------------

    // it 'should import JavaScript/CoffeeScript files listed in a .js.yaml file', build
    //   root: "#{fixtures}/build/yaml-js"
    //   files: [
    //     'src/_1.js'
    //     'src/_2.coffee'
    //     'src/import.js.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/yaml-js/build/import.js").to.have.content """
    //       f1();

    //       (function() {
    //         f2();

    //       }).call(this);\n
    //     """


    // it 'should import CSS/Sass files listed in a .css.yaml file', build
    //   root: "#{fixtures}/build/yaml-css"
    //   files: [
    //     'src/_1.css'
    //     'src/_2.scss'
    //     'src/import.css.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/yaml-css/build/import.css").to.have.content """
    //       .css {
    //         color: red;
    //       }

    //       .scss, .also-scss {
    //         color: green;
    //       }\n
    //     """


    // it 'should not attempt to import files from other .yaml files', build
    //   root: "#{fixtures}/build/yaml-other"
    //   files: [
    //     'src/import.txt.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/yaml-other/build/import.txt").not.to.be.a.path()
    //     expect("#{fixtures}/build/yaml-other/build/import.txt.yaml").to.be.have.content """
    //       - SHOULD NOT BE IMPORTED\n
    //     """


    // it 'should allow imports outside the source directory in YAML files', build
    //   root: "#{fixtures}/build/yaml-error"
    //   files: [
    //     'outside.js'
    //     'src/_1.js'
    //     'src/_2.js'
    //     'src/import.js.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/yaml-error/build/import.js").to.have.content """
    //       f1();\n
    //       f2();\n
    //       f3();\n
    //     """


    // it 'should import YAML files nested inside other YAML files', build
    //   root: "#{fixtures}/build/yaml-nested"
    //   files: [
    //     'src/_script.js'
    //     'src/_nested.js.yaml'
    //     'src/import.js.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/yaml-nested/build/import.js").to.have.content """
    //       console.log('JavaScript');\n
    //     """


    // it 'should import files listed in a YAML file inside a combined directory', build
    //   root: "#{fixtures}/build/combine-yaml"
    //   files: [
    //     'src/combine.js/1.js'
    //     'src/combine.js/2-3.js.yaml'
    //     'src/combine.js/4.js'
    //     'src/_2.js'
    //     'src/_3.js'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/combine-yaml/build/combine.js").to.have.content """
    //       f1();\n
    //       f2();\n
    //       f3();\n
    //       f4();\n
    //     """


    // it 'should combine files in a directory listed in a YAML file', build
    //   root: "#{fixtures}/build/yaml-combine"
    //   files: [
    //     'src/_1.js'
    //     'src/_23.js/2.js'
    //     'src/_23.js/3.js'
    //     'src/_4.js'
    //     'src/import.js.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/yaml-combine/build/import.js").to.have.content """
    //       f1();\n
    //       f2();\n
    //       f3();\n
    //       f4();\n
    //     """


    // it 'should show an error if a file cannot be found', build
    //   root: "#{fixtures}/build/yaml-missing"
    //   files: [
    //     'src/import-error.js.yaml'
    //   ]
    //   errors: 1


    // #----------------------------------------
    // # Autoprefixer
    // #----------------------------------------

    // it 'should add cross-browser prefixes to .css files when Autoprefixer is enabled', build
    //   root: "#{fixtures}/build/autoprefixer-css"
    //   config:
    //     autoprefixer: true
    //   files: [
    //     'src/autoprefixer.css'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/autoprefixer-css/build/autoprefixer.css").to.have.content """
    //       .css {
    //         -webkit-transition: -webkit-transform 1s;
    //                 transition: transform 1s;
    //       }\n\n
    //     """


    // it 'should add cross-browser prefixes to .scss files when Autoprefixer is enabled', build
    //   root: "#{fixtures}/build/autoprefixer-scss"
    //   config:
    //     autoprefixer: true
    //   files: [
    //     'src/autoprefixer.scss'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/autoprefixer-scss/build/autoprefixer.css").to.have.content """
    //       .scss, .also-scss {
    //         -webkit-transition: -webkit-transform 1s;
    //                 transition: transform 1s;
    //       }\n
    //     """


    // it 'should NOT add cross-browser prefixes to non-CSS files', build
    //   root: "#{fixtures}/build/autoprefixer-other"
    //   config:
    //     autoprefixer: true
    //   files: [
    //     'src/autoprefixer.txt'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/autoprefixer-other/build/autoprefixer.txt").to.have.content """
    //       .not-css {
    //         transition: transform 1s;
    //       }\n
    //     """

    /*--------------------------------------
     Bower
    --------------------------------------*/

    public function testCreatesASymlinkToBowerDirectory()
    {
        $this->build($root = "{$this->fixtures}/build/bower-symlink", ['bower' => 'bower_components/']);

        $this->assertFileExists("$root/build/_bower");
        $this->assertTrue(is_link("$root/build/_bower"), "Expected '$root/build/_bower' to be a symlink");
        $this->assertTrue(is_dir("$root/build/_bower"), "Expected '$root/build/_bower' to be a directory");
        $this->assertFileExists("$root/build/_bower/bower.txt");
    }

    public function testShowsAWarningAndDoesntCreateASymlinkIfBowerDirectoryDoesNotExist()
    {
        $this->build($root = "{$this->fixtures}/build/bower-missing", ['bower' => 'bower_components/']);

        // warnings: 1
        $this->assertFileNotExists("$root/build/_bower");
    }

    public function testDoesntCreateASymlinkIfBowerOptionIsFalse()
    {
        $this->build($root = "{$this->fixtures}/build/bower-disabled", ['bower' => false]);

        $this->assertFileNotExists("$root/build/_bower");
    }

    /*--------------------------------------
     URL rewriting
    --------------------------------------*/
    // For full tests see UrlRewriterTest.php - this just checks they are applied correctly

    // it 'should rewrite relative URLs in directory-combined CSS files', build
    //   root: "#{fixtures}/build/rewrite-combined"
    //   config:
    //     bower: 'bower_components/'
    //   files: [
    //     'bower_components/sample.gif'
    //     'src/combine.css/styles.css'
    //     'src/sample.gif'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/rewrite-combined/build/combine.css").to.have.content """
    //       .relative {
    //         background: url(sample.gif);
    //       }
    //       .bower {
    //         background: url(_bower/sample.gif);
    //       }\n
    //     """


    // it 'should rewrite relative URLs to Bower files', build
    //   root: "#{fixtures}/build/rewrite-bower"
    //   config:
    //     bower: 'bower_components/'
    //   files: [
    //     'bower_components/sample.gif'
    //     'bower_components/target.css'
    //     'src/subdir/bower.css.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/rewrite-bower/build/subdir/bower.css").to.have.content """
    //       body {
    //         background: url(../_bower/sample.gif);
    //       }\n
    //     """


    // it 'should rewrite relative URLs to outside files', build
    //   root: "#{fixtures}/build/rewrite-outside"
    //   files: [
    //     'sample.gif'
    //     'target.css'
    //     'src/outside.css.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/rewrite-outside/build/outside.css").to.have.content """
    //       body {
    //         background: url(../sample.gif);
    //       }\n
    //     """


    // it 'should rewrite relative URLs in YAML-imported CSS files', build
    //   root: "#{fixtures}/build/rewrite-yaml"
    //   config:
    //     bower: 'bower_components/'
    //   files: [
    //     'bower_components/sample.gif'
    //     'src/_import/styles.css'
    //     'src/import.css.yaml'
    //     'src/sample.gif'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/rewrite-yaml/build/import.css").to.have.content """
    //       .relative {
    //         background: url(sample.gif);
    //       }
    //       .bower {
    //         background: url(_bower/sample.gif);
    //       }\n
    //     """


    // it 'should warn about invalid relative URLs in CSS, but leave them unchanged', build
    //   root: "#{fixtures}/build/rewrite-invalid"
    //   files: [
    //     'src/invalid-url.css'
    //   ]
    //   warnings: 1
    //   tests: ->
    //     expect("#{fixtures}/build/rewrite-invalid/build/invalid-url.css").to.have.content """
    //       body {
    //         background: url(invalid.gif);
    //       }\n
    //     """


    /*--------------------------------------
     Source maps
    --------------------------------------*/

    public function testDoesntCreateMapFileIfSourceMapsAreDisabled()
    {
        $this->build($root = "{$this->fixtures}/build/sourcemap-disabled", ['sourcemaps' => false]);

        $this->assertFileExists("$root/build/coffeescript.js");
        $this->assertFileNotExists("$root/build/coffeescript.js.map");
    }

    public function testCreatesSourceMapsForCoffeescript()
    {
        $this->build($root = "{$this->fixtures}/build/sourcemap-coffeescript", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/coffeescript.js", "$root/build/coffeescript.js");
        $this->assertFileEquals("$root/expected/coffeescript.js.map", "$root/build/coffeescript.js.map");
    }

    // it 'should create sourcemaps for CSS with Autoprefixer', build
    //   root: "#{fixtures}/build/sourcemap-css-autoprefixer"
    //   config:
    //     sourcemaps: true
    //     autoprefixer: true
    //   files: [
    //     'src/styles.css'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/sourcemap-css-autoprefixer/build/styles.css").to.have.content """
    //       /* This is just to make the line numbers change a bit */
    //       .another {
    //         -webkit-transition: -webkit-transform 1s;
    //                 transition: transform 1s;
    //       }

    //       .css {
    //         -webkit-transition: -webkit-transform 1s;
    //                 transition: transform 1s;
    //       }

    //       /*# sourceMappingURL=styles.css.map */\n
    //     """
    //     expect("#{fixtures}/build/sourcemap-css-autoprefixer/build/styles.css.map").to.have.content """
    //       {
    //         "version": 3,
    //         "sources": [
    //           "styles.css"
    //         ],
    //         "names": [],
    //         "mappings": "AAAA,yDAAwD;AACxD;EACE,0CAAyB;UAAzB,0BAAyB;EAC1B;;AAED;EACE,0CAAyB;UAAzB,0BAAyB;EAC1B",
    //         "file": "styles.css",
    //         "sourceRoot": "../src",
    //         "sourcesContent": [
    //           "/* This is just to make the line numbers change a bit */\\n.another {\\n  transition: transform 1s;\\n}\\n\\n.css {\\n  transition: transform 1s;\\n}\\n"
    //         ]
    //       }
    //     """

    public function testCreatesSourceMapsForScssFiles()
    {
        $this->build($root = "{$this->fixtures}/build/sourcemap-sass", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/sass.css", "$root/build/sass.css");
        $this->assertFileEquals("$root/expected/sass.css.map", "$root/build/sass.css.map");
    }

    // public function testCreatesSourceMapsForScssFilesWithSprites()
    // {
    //     $this->build($root = "{$this->fixtures}/build/sourcemap-compass-sprites", ['sourcemaps' => true]);

    //     $this->assertFileEquals("$root/expected/sprite.css", "$root/build/sprite.css");
    //     $this->assertFileEquals("$root/expected/sprite.css.map", "$root/build/sprite.css.map");
    // }

    // it 'should create sourcemaps for combined JavaScript directories', build
    //   root: "#{fixtures}/build/sourcemap-combine-js"
    //   config:
    //     sourcemaps: true
    //   files: [
    //     'src/combine.js/1.js'
    //     'src/combine.js/2-subdir/2.coffee'
    //     'src/combine.js/_ignored.coffee'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/sourcemap-combine-js/build/combine.js").to.have.content """
    //       // This is just to move it down a line
    //       console.log('JavaScript');

    //       (function() {
    //         console.log('CoffeeScript');

    //       }).call(this);

    //       //# sourceMappingURL=combine.js.map\n
    //     """
    //     expect("#{fixtures}/build/sourcemap-combine-js/build/combine.js.map").to.have.content """
    //       {
    //         "version": 3,
    //         "sources": [
    //           "combine.js/1.js",
    //           "combine.js/2-subdir/2.coffee"
    //         ],
    //         "names": [],
    //         "mappings": "AAAA;AACA;AACA;ACAA;AAAA,EAAA,OAAO,CAAC,GAAR,CAAY,cAAZ,CAAA,CAAA;AAAA",
    //         "file": "combine.js",
    //         "sourceRoot": "../src",
    //         "sourcesContent": [
    //           "// This is just to move it down a line\\nconsole.log('JavaScript');\\n",
    //           "# This is just to move it down a couple\\n# of lines\\nconsole.log 'CoffeeScript'\\n"
    //         ]
    //       }
    //     """


    // it 'should create sourcemaps for combined CSS directories', build
    //   root: "#{fixtures}/build/sourcemap-combine-css"
    //   config:
    //     sourcemaps: true
    //   files: [
    //     'src/combine.css/_vars.scss'
    //     'src/combine.css/1.css'
    //     'src/combine.css/2-subdir/2.scss'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/sourcemap-combine-css/build/combine.css").to.have.content """
    //       .css {
    //         color: red;
    //       }

    //       .scss, .also-scss {
    //         font-weight: bold;
    //       }

    //       /*# sourceMappingURL=combine.css.map */\n
    //     """
    //     expect("#{fixtures}/build/sourcemap-combine-css/build/combine.css.map").to.have.content """
    //       {
    //         "version": 3,
    //         "sources": [
    //           "combine.css/1.css",
    //           "combine.css/2-subdir/2.scss"
    //         ],
    //         "names": [],
    //         "mappings": "AAAA;EACE,YAAW;EACZ;;ACDD;EACE,mBAAiB;EAAlB",
    //         "file": "combine.css",
    //         "sourceRoot": "../src",
    //         "sourcesContent": [
    //           ".css {\\n  color: red;\\n}\\n",
    //           "// This comment is just to change the line numbers\\n.scss {\\n  font-weight: bold;\\n}\\n\\n.also-scss {\\n  @extend .scss;\\n}\\n"
    //         ]
    //       }
    //     """


    // it 'should create sourcemaps for YAML imports', build
    //   root: "#{fixtures}/build/sourcemap-yaml-combine"
    //   config:
    //     sourcemaps: true
    //   files: [
    //     'src/_1.js'
    //     'src/_23.js/2.js'
    //     'src/_23.js/3.js'
    //     'src/_4.js'
    //     'src/import.js.yaml'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/sourcemap-yaml-combine/build/import.js").to.have.content """
    //       console.log('File 1');

    //       // This is just to move it down a line
    //       console.log('File 2');

    //       // This is just to move it down 2 lines
    //       // This is just to move it down 2 lines
    //       console.log('File 3');

    //       // This is just to move it down 3 lines
    //       // This is just to move it down 3 lines
    //       // This is just to move it down 3 lines
    //       console.log('File 4');

    //       //# sourceMappingURL=import.js.map\n
    //     """
    //     expect("#{fixtures}/build/sourcemap-yaml-combine/build/import.js.map").to.have.content """
    //       {
    //         "version": 3,
    //         "sources": [
    //           "_1.js",
    //           "_23.js/2.js",
    //           "_23.js/3.js",
    //           "_4.js"
    //         ],
    //         "names": [],
    //         "mappings": "AAAA;AACA;ACDA;AACA;AACA;ACFA;AACA;AACA;AACA;ACHA;AACA;AACA;AACA;AACA",
    //         "file": "import.js",
    //         "sourceRoot": "../src",
    //         "sourcesContent": [
    //           "console.log('File 1');\\n",
    //           "// This is just to move it down a line\\nconsole.log('File 2');\\n",
    //           "// This is just to move it down 2 lines\\n// This is just to move it down 2 lines\\nconsole.log('File 3');\\n",
    //           "// This is just to move it down 3 lines\\n// This is just to move it down 3 lines\\n// This is just to move it down 3 lines\\nconsole.log('File 4');\\n"
    //         ]
    //       }
    //     """


    // it 'should support sourcemaps for empty CSS files', build
    //   # This is because concat-with-sourcemaps crashes on empty CSS files -
    //   # probably an incompatibility with PostCSS since JS files are fine
    //   root: "#{fixtures}/build/sourcemap-combine-empty"
    //   config:
    //     sourcemaps: true
    //   files: [
    //     'src/dir.css/empty.css'
    //   ]
    //   tests: ->
    //     expect("#{fixtures}/build/sourcemap-combine-empty/build/dir.css").to.have.content """
    //       \n\n/*# sourceMappingURL=dir.css.map */\n
    //     """
    //     expect("#{fixtures}/build/sourcemap-combine-empty/build/dir.css.map").to.have.content """
    //       {
    //         "version": 3,
    //         "sources": [
    //           "dir.css/empty.css"
    //         ],
    //         "names": [],
    //         "mappings": "AAAA;AACA",
    //         "file": "dir.css",
    //         "sourceRoot": "../src",
    //         "sourcesContent": [
    //           ""
    //         ]
    //       }
    //     """

    public function testCreatesSourceMapForEmptyScssFile()
    {
        $this->build($root = "{$this->fixtures}/build/sourcemap-empty-sass", ['sourcemaps' => true]);

        $this->assertFileEquals("$root/expected/empty.css", "$root/build/empty.css");
        $this->assertFileEquals("$root/expected/empty.css.map", "$root/build/empty.css.map");
    }

    /*--------------------------------------
     Miscellaneous
    --------------------------------------*/

    public function testPutsCacheFilesInHiddenDirectoryAndCreatesGitignoreFile()
    {
        $this->build($root = "{$this->fixtures}/build/cache");

        $this->assertFileExists("$root/.awe");
        $this->assertFileExists("$root/.awe/sass-cache");
        $this->assertFileEquals("$root/expected/.gitignore", "$root/.awe/.gitignore");
    }

    // it "should display an error and not create the build directory if the source directory doesn't exist", build
    //   root: "#{fixtures}/build/src-missing"
    //   files: [
    //     '.gitkeep'
    //   ]
    //   errors: 1
    //   tests: ->
    //     expect("#{fixtures}/build/src-missing/build").not.to.be.a.path()

    public function testCreatesAFileWarningUsersNotToEditFilesInTheBuildDirectory()
    {
        $this->build($root = "{$this->fixtures}/build/warning-file", ['warningfile' => true]);

        $this->assertFileEquals("$root/expected/_DO_NOT_EDIT.txt", "$root/build/_DO_NOT_EDIT.txt");
    }
}
