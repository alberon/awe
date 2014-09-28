_          = require('lodash')
AssetGroup = require('../lib/AssetGroup')
expect     = require('chai').use(require('chai-fs')).expect
fs         = require('fs')
output     = require('../lib/output')
path       = require('path')
rmdir      = require('rimraf').sync

fixtures = path.resolve(__dirname, '../fixtures')

#================================================================================
# Settings
#================================================================================

# Set this to true to display only the results (this should be the default)
# Set it to false if you want to see the full build output
quiet = true


#================================================================================
# Helper
#================================================================================

build = ({root, files, config, warnings, errors, tests}) ->
  # Return a function for Mocha to run asynchronously
  (done) ->
    # Default config settings
    config = _.defaults {}, config,
      src:          'src/'
      dest:         'build/'
      bower:        false
      autoprefixer: false
      sourcemaps:   false

    # Check all the listed files exist - this is partly to double-check the
    # directory structure, and partly a way to document it
    if files
      for file in files
        expect("#{root}/#{file}").to.be.a.path('TEST SETUP ERROR')

    # Clear the cache and build directories
    rmdir("#{root}/.awe")
    rmdir("#{root}/#{config.dest}")

    # Disable output?
    output.disable() if quiet

    # Insert a blank line to separate build output from the previous test
    output.line()
    output.building()

    # Start counting warnings & errors
    output.resetCounters()

    # Build it
    (new AssetGroup(root, config)).build (err, result) ->
      # Insert another blank line to separate build output from the test results
      output.finished()
      output.line()

      # Re-enable output
      output.enable() if quiet

      # Get us outside any try..catch blocks that interfere with assertions
      process.nextTick ->
        # Check for unhandled errors
        throw new Error(err) if err

        # Check for error/warning messages
        expect(output.counters.error || 0).to.equal(errors || 0, "Expected #{errors || 'no'} error(s)")
        expect(output.counters.warning || 0).to.equal(warnings || 0, "Expected #{warnings || 'no'} error(s)")

        # Run tests (synchronously)
        tests()

        # Tell Mocha we're done
        done()


#================================================================================
# Tests
#================================================================================

describe 'AssetGroup.build()', ->

  #----------------------------------------
  # Basic copy/compile functionality
  #----------------------------------------

  it 'should copy JavaScript, CSS and unknown files', build
    root: "#{fixtures}/build-copy"
    files: [
      'src/javascript.js'
      'src/stylesheet.css'
      'src/unknown.file'
    ]
    tests: ->
      expect("#{fixtures}/build-copy/build/javascript.js").to.have.content """
        console.log('JavaScript');\n
      """

      expect("#{fixtures}/build-copy/build/stylesheet.css").to.have.content """
        .red {
          color: red;
        }
      """

      expect("#{fixtures}/build-copy/build/unknown.file").to.have.content """
        Unknown\n
      """


  it 'should compile CoffeeScript files', build
    root: "#{fixtures}/build-coffeescript"
    files: [
      'src/coffeescript.coffee'
    ]
    tests: ->
      expect("#{fixtures}/build-coffeescript/build/coffeescript.js").to.have.content """
        (function() {
          console.log('JavaScript');

        }).call(this);\n
      """


  it 'should compile SASS files', build
    root: "#{fixtures}/build-sass"
    files: [
      'src/sass.scss'
    ]
    tests: ->
      expect("#{fixtures}/build-sass/build/sass.css").to.have.content """
        .main-red,
        .also-red {
          color: red;
        }
      """


  it 'should skip files starting with an underscore', build
    root: "#{fixtures}/build-underscores"
    files: [
      'src/_ignored.coffee'
      'src/_vars.scss'
    ]
    tests: ->
      expect("#{fixtures}/build-underscores/_ignored.coffee").not.to.be.a.path()
      expect("#{fixtures}/build-underscores/_ignored.js").not.to.be.a.path()
      expect("#{fixtures}/build-underscores/_vars.scss").not.to.be.a.path()
      expect("#{fixtures}/build-underscores/_vars.css").not.to.be.a.path()


  #----------------------------------------
  # Compass
  #----------------------------------------

  it 'should use relative paths for Compass URL helpers', build
    root: "#{fixtures}/build-compass-urls"
    files: [
      'src/subdir/urls.scss'
    ]
    tests: ->
      expect("#{fixtures}/build-compass-urls/build/subdir/urls.css").to.have.content """
        .imageUrl {
          background: url('../img/sample.gif');
        }

        @font-face {
          font-family: myfont;
          src: url('../fonts/myfont.woff');
        }
      """


  it 'should support the Compass inline-image() helper', build
    root: "#{fixtures}/build-compass-inline"
    files: [
      'src/img/_blank.gif'
      'src/inline.scss'
    ]
    tests: ->
      expect("#{fixtures}/build-compass-inline/build/inline.css").to.have.content """
        .inlineImage {
          background: url('data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAQAIBRAA7');
        }
      """


  it 'should support Compass sprites', build
    root: "#{fixtures}/build-compass-sprites"
    files: [
      'src/_sprites/icons/icon1.png'
      'src/_sprites/icons/icon2.png'
      'src/sprite.scss'
    ]
    tests: ->
      # CSS file content must match
      content = fs.readFileSync("#{fixtures}/build-compass-sprites/build/sprite.css", 'utf8')
      expect(content).to.match /\.icons-sprite,\n\.icons-icon1,\n\.icons-icon2 {/
      expect(content).to.match /background-image: url\('_generated\/icons-[^']+\.png'\);/

      # Generated sprite must exist
      sprite = content.match(/background-image: url\('_generated\/(icons-[^']+\.png)'\);/)[1]
      expect("#{fixtures}/build-compass-sprites/build/_generated/#{sprite}").to.be.a.file()


  #----------------------------------------
  # Symlinks
  #----------------------------------------

  it 'should convert symlinks to files to regular files', build
    root: "#{fixtures}/build-symlink-files"
    files: [
      'src/file.txt'
      'src/symlink.txt' # -> file.txt
    ]
    tests: ->
      expect("#{fixtures}/build-symlink-files/build/file.txt").to.be.a.file()
      expect("#{fixtures}/build-symlink-files/build/file.txt").not.to.be.a.symlink()
      expect("#{fixtures}/build-symlink-files/build/symlink.txt").to.be.a.file()
      expect("#{fixtures}/build-symlink-files/build/symlink.txt").not.to.be.a.symlink()


  it 'should convert symlinks to directories to regular directories', build
    root: "#{fixtures}/build-symlink-dirs"
    files: [
      'src/orig/file.txt'
      'src/symlink' # -> orig/
    ]
    tests: ->
      expect("#{fixtures}/build-symlink-dirs/build/orig").to.be.a.directory()
      expect("#{fixtures}/build-symlink-dirs/build/orig").not.to.be.a.symlink()
      expect("#{fixtures}/build-symlink-dirs/build/orig/file.txt").to.be.a.file()
      expect("#{fixtures}/build-symlink-dirs/build/symlink").to.be.a.directory()
      expect("#{fixtures}/build-symlink-dirs/build/symlink").not.to.be.a.symlink()
      expect("#{fixtures}/build-symlink-dirs/build/symlink/file.txt").to.be.a.file()


  it 'should detect infinite symlink loops and skip them with an error message', build
    root: "#{fixtures}/build-symlink-loop"
    files: [
      'src/a/b' # -> b
      'src/b/a' # -> a
      'src/subdir/file.txt'
      'src/subdir/symlink' # -> subdir/
      'src/symlink' # -> ./
    ]
    errors: 4
    tests: ->
      expect("#{fixtures}/build-symlink-loop/build/symlink").not.to.be.a.path()
      expect("#{fixtures}/build-symlink-loop/build/subdir").to.be.a.directory()
      expect("#{fixtures}/build-symlink-loop/build/subdir/file.txt").to.be.a.file()
      expect("#{fixtures}/build-symlink-loop/build/subdir/symlink").not.to.be.a.path()


  #----------------------------------------
  # Combine directories
  #----------------------------------------

  it 'should combine the content of *.js/ directories', build
    root: "#{fixtures}/build-combine-js"
    files: [
      'src/combine.js/_ignored.coffee'
      'src/combine.js/1.js'
      'src/combine.js/2-subdir/2.coffee'
    ]
    tests: ->
      expect("#{fixtures}/build-combine-js/build/combine.js").to.have.content """
        f1();

        (function() {
          f2();

        }).call(this);\n
      """


  it 'should combine the content of *.css/ directories', build
    root: "#{fixtures}/build-combine-css"
    files: [
      'src/combine.css/_vars.scss'
      'src/combine.css/1.css'
      'src/combine.css/2-subdir/2.scss'
    ]
    tests: ->
      expect("#{fixtures}/build-combine-css/build/combine.css").to.have.content """
        .css {
          color: red;
        }
        .scss,
        .also-scss {
          color: green;
        }
      """


  it 'should not combine the content of *.other/ directories', build
    root: "#{fixtures}/build-combine-other"
    files: [
      'src/combine.other/sample.txt'
    ]
    tests: ->
      expect("#{fixtures}/build-combine-other/build/combine.other").to.be.a.directory()
      expect("#{fixtures}/build-combine-other/build/combine.other/sample.txt").to.be.a.file()


  it 'should detect infinite symlink loops in combined directories and skip them with an error message', build
    root: "#{fixtures}/build-combine-loop"
    files: [
      'src/combine.css/a/b' # -> combine.css/b
      'src/combine.css/b/a' # -> combine.css/a
      'src/combine.css/subdir/file.css'
      'src/combine.css/subdir/symlink' # -> combine.css/subdir/
      'src/combine.css/symlink' # -> combine.css/
    ]
    errors: 4
    tests: ->
      expect("#{fixtures}/build-combine-loop/build/combine.css").to.have.content """
        body {
          color: red;
        }
      """


  #----------------------------------------
  # YAML imports
  #----------------------------------------

  it 'should import JavaScript/CoffeeScript files listed in a .js.yaml file', build
    root: "#{fixtures}/build-yaml-js"
    files: [
      'src/_1.js'
      'src/_2.coffee'
      'src/import.js.yaml'
    ]
    tests: ->
      expect("#{fixtures}/build-yaml-js/build/import.js").to.have.content """
        f1();

        (function() {
          f2();

        }).call(this);\n
      """


  it 'should import CSS/Sass files listed in a .css.yaml file', build
    root: "#{fixtures}/build-yaml-css"
    files: [
      'src/_1.css'
      'src/_2.scss'
      'src/import.css.yaml'
    ]
    tests: ->
      expect("#{fixtures}/build-yaml-css/build/import.css").to.have.content """
        .css {
          color: red;
        }
        .scss,
        .also-scss {
          color: green;
        }
      """


  it 'should not attempt to import files from other .yaml files', build
    root: "#{fixtures}/build-yaml-other"
    files: [
      'src/import.txt.yaml'
    ]
    tests: ->
      expect("#{fixtures}/build-yaml-other/build/import.txt").not.to.be.a.path()
      expect("#{fixtures}/build-yaml-other/build/import.txt.yaml").to.be.have.content """
        - SHOULD NOT BE IMPORTED\n
      """


  it 'should skip imports outside the source directory in YAML files', build
    root: "#{fixtures}/build-yaml-error"
    files: [
      'outside.js'
      'src/_1.js'
      'src/_2.js'
      'src/import.js.yaml'
    ]
    errors: 1
    tests: ->
      expect("#{fixtures}/build-yaml-error/build/import.js").to.have.content """
        f1();\n
        f2();\n
      """


  it 'should import YAML files nested inside other YAML files', build
    root: "#{fixtures}/build-yaml-nested"
    files: [
      'src/_script.js'
      'src/_nested.js.yaml'
      'src/import.js.yaml'
    ]
    tests: ->
      expect("#{fixtures}/build-yaml-nested/build/import.js").to.have.content """
        console.log('JavaScript');\n
      """


  it 'should import files listed in a YAML file inside a combined directory', build
    root: "#{fixtures}/build-combine-yaml"
    files: [
      'src/combine.js/1.js'
      'src/combine.js/2-3.js.yaml'
      'src/combine.js/4.js'
      'src/_2.js'
      'src/_3.js'
    ]
    tests: ->
      expect("#{fixtures}/build-combine-yaml/build/combine.js").to.have.content """
        f1();\n
        f2();\n
        f3();\n
        f4();\n
      """


  it 'should combine files in a directory listed in a YAML file', build
    root: "#{fixtures}/build-yaml-combine"
    files: [
      'src/_1.js'
      'src/_23.js/2.js'
      'src/_23.js/3.js'
      'src/_4.js'
      'src/import.js.yaml'
    ]
    tests: ->
      expect("#{fixtures}/build-yaml-combine/build/import.js").to.have.content """
        f1();\n
        f2();\n
        f3();\n
        f4();\n
      """


  #----------------------------------------
  # Autoprefixer
  #----------------------------------------

  it 'should add cross-browser prefixes to .css files when Autoprefixer is enabled', build
    root: "#{fixtures}/build-autoprefixer-css"
    config:
      autoprefixer: true
    files: [
      'src/autoprefixer.css'
    ]
    tests: ->
      # Note: Autoprefixer seems to remove the \n from the end
      expect("#{fixtures}/build-autoprefixer-css/build/autoprefixer.css").to.have.content """
        .css {
          -webkit-transition: -webkit-transform 1s;
                  transition: transform 1s;
        }
      """


  it 'should add cross-browser prefixes to .scss files when Autoprefixer is enabled', build
    root: "#{fixtures}/build-autoprefixer-scss"
    config:
      autoprefixer: true
    files: [
      'src/autoprefixer.scss'
    ]
    tests: ->
      expect("#{fixtures}/build-autoprefixer-scss/build/autoprefixer.css").to.have.content """
        .scss,
        .also-scss {
          -webkit-transition: -webkit-transform 1s;
                  transition: transform 1s;
        }
      """


  it 'should NOT add cross-browser prefixes to non-CSS files', build
    root: "#{fixtures}/build-autoprefixer-other"
    config:
      autoprefixer: true
    files: [
      'src/autoprefixer.txt'
    ]
    tests: ->
      expect("#{fixtures}/build-autoprefixer-other/build/autoprefixer.txt").to.have.content """
        .not-css {
          transition: transform 1s;
        }\n
      """


  #----------------------------------------
  # Bower
  #----------------------------------------

  it 'should create a symlink to bower_components/', build
    root: "#{fixtures}/build-bower-symlink"
    config:
      bower: 'bower_components/'
    files: [
      'bower_components/bower.txt'
      'src/_source'
    ]
    tests: ->
      expect("#{fixtures}/build-bower-symlink/build/_bower").to.be.a.symlink()
      expect("#{fixtures}/build-bower-symlink/build/_bower").to.be.a.directory()
      expect("#{fixtures}/build-bower-symlink/build/_bower/bower.txt").to.be.a.file()


  it 'should not create a symlink if the bower target directory does not exist', build
    root: "#{fixtures}/build-bower-missing"
    config:
      bower: 'bower_components/'
    files: [
      'src/_source'
    ]
    tests: ->
      expect("#{fixtures}/build-bower-missing/build/_bower").not.to.be.a.symlink()
      expect("#{fixtures}/build-bower-missing/build/_bower").not.to.be.a.path()


  it 'should not create a symlink to bower_components/ if set to false', build
    root: "#{fixtures}/build-bower-disabled"
    config:
      bower: false
    files: [
      'src/_source'
    ]
    tests: ->
      expect("#{fixtures}/build-bower-disabled/build/_bower").not.to.be.a.symlink()
      expect("#{fixtures}/build-bower-disabled/build/_bower").not.to.be.a.path()


  #----------------------------------------
  # URL rewriting
  #----------------------------------------
  # For full tests see UrlRewriter.coffee - this just checks they are applied correctly

  it 'should rewrite relative URLs in symlinked files', build
    root: "#{fixtures}/build-rewrite-symlink"
    files: [
      'src/sample.gif'
      'src/target.css'
      'src/subdir/local-symlink.css'
    ]
    tests: ->
      expect("#{fixtures}/build-rewrite-symlink/build/subdir/local-symlink.css").to.have.content """
        body {
          background: url(../sample.gif);
        }
      """


  it 'should rewrite relative URLs in Bower symlinked files', build
    root: "#{fixtures}/build-rewrite-bower"
    config:
      bower: 'bower_components/'
    files: [
      'bower_components/sample.gif'
      'bower_components/target.css'
      'src/subdir/bower-symlink.css'
    ]
    tests: ->
      expect("#{fixtures}/build-rewrite-bower/build/subdir/bower-symlink.css").to.have.content """
        body {
          background: url(../_bower/sample.gif);
        }
      """


  it 'should rewrite relative URLs in directory-combined CSS files', build
    root: "#{fixtures}/build-rewrite-combined"
    config:
      bower: 'bower_components/'
    files: [
      'bower_components/sample.gif'
      'src/combine.css/styles.css'
      'src/sample.gif'
    ]
    tests: ->
      expect("#{fixtures}/build-rewrite-combined/build/combine.css").to.have.content """
        .relative {
          background: url(sample.gif);
        }

        .bower {
          background: url(_bower/sample.gif);
        }
      """


  it 'should rewrite relative URLs in YAML-imported CSS files', build
    root: "#{fixtures}/build-rewrite-yaml"
    config:
      bower: 'bower_components/'
    files: [
      'bower_components/sample.gif'
      'src/_import/styles.css'
      'src/import.css.yaml'
      'src/sample.gif'
    ]
    tests: ->
      expect("#{fixtures}/build-rewrite-yaml/build/import.css").to.have.content """
        .relative {
          background: url(sample.gif);
        }

        .bower {
          background: url(_bower/sample.gif);
        }
      """


  it 'should warn about invalid relative URLs in CSS, but leave them unchanged', build
    root: "#{fixtures}/build-rewrite-invalid"
    files: [
      'src/invalid-url.css'
    ]
    warnings: 1
    tests: ->
      expect("#{fixtures}/build-rewrite-invalid/build/invalid-url.css").to.have.content """
        body {
          background: url(invalid.gif);
        }
      """


  #----------------------------------------
  # Source maps
  #----------------------------------------

  it 'should create a symlink to the source files (for sourcemaps support)', build
    root: "#{fixtures}/build-sourcemap-symlink"
    config:
      sourcemaps: true
    files: [
      'src/_source'
    ]
    tests: ->
      expect("#{fixtures}/build-sourcemap-symlink/build/_src").to.be.a.directory()
      expect("#{fixtures}/build-sourcemap-symlink/build/_src").to.be.a.symlink()
      expect("#{fixtures}/build-sourcemap-symlink/build/_src/_source").to.be.a.file()


  it 'should not create a symlink to the source files if sourcemaps are disabled', build
    root: "#{fixtures}/build-sourcemap-disabled"
    files: [
      'src/_source'
    ]
    tests: ->
      expect("#{fixtures}/build-sourcemap-disabled/build/_src").not.to.be.a.symlink()
      expect("#{fixtures}/build-sourcemap-disabled/build/_src").not.to.be.a.path()


  it 'should create sourcemaps for CoffeeScript', build
    root: "#{fixtures}/build-sourcemap-coffeescript"
    config:
      sourcemaps: true
    files: [
      'src/coffeescript.coffee'
    ]
    tests: ->
      expect("#{fixtures}/build-sourcemap-coffeescript/build/coffeescript.js").to.have.content """
        (function() {
          console.log('JavaScript');

        }).call(this);

        //# sourceMappingURL=coffeescript.js.map\n
      """
      expect("#{fixtures}/build-sourcemap-coffeescript/build/coffeescript.js.map").to.have.content """
        {
          "version": 3,
          "file": "coffeescript.js",
          "sourceRoot": "_src",
          "sources": [
            "coffeescript.coffee"
          ],
          "names": [],
          "mappings": "AAAA;AAAA,EAAA,OAAO,CAAC,GAAR,CAAY,YAAZ,CAAA,CAAA;AAAA"
        }
      """


  # TODO: Generate sourcemaps for each type of file:
  # - CSS
  # - CoffeeScript
  # - Sass
  # - Combined directories
  # - Imported YAML files


  #----------------------------------------
  # Miscellaneous
  #----------------------------------------

  it 'should put cache files in .awe/ and create a .gitignore file', build
    root: "#{fixtures}/build-cache"
    files: [
      'src/styles.scss'
    ]
    tests: ->
      expect("#{fixtures}/build-cache/.awe/sass-cache").to.be.a.directory()
      expect("#{fixtures}/build-cache/.awe/.gitignore").to.be.a.file()


  it "should display an error and not create the build directory if the source directory doesn't exist", build
    root: "#{fixtures}/build-src-missing"
    files: [
      '.gitkeep'
    ]
    errors: 1
    tests: ->
      expect("#{fixtures}/build-src-missing/build").not.to.be.a.path()
