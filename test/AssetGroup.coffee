_          = require('lodash')
AssetGroup = require('../lib/AssetGroup')
expect     = require('chai').use(require('chai-fs')).use(require('./_helpers')).expect
fs         = require('fs')
path       = require('path')
rmdir      = require('rimraf').sync

fixtures = path.resolve(__dirname, '../fixtures')

#================================================================================
# Helper
#================================================================================

build = ({root, config, tests}) ->
  # Return a function for Mocha to run asynchronously
  (done) ->
    # Default config settings
    config = _.defaults {}, config,
      src:          'src/'
      dest:         'build/'
      bower:        false
      autoprefixer: false

    # Clear the cache and build directories
    rmdir("#{root}/.awe")
    rmdir("#{root}/#{config.dest}")

    # Insert a blank line to separate build output from the previous test
    console.log()

    # Build it
    (new AssetGroup(root, config)).build (err) ->
      # Insert another blank line to separate build output from the test results
      console.log()

      # Get us outside any try..catch blocks that interfere with assertions
      process.nextTick ->
        # Check for errors
        throw new Error(err) if err
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

  it 'should create a symlink to the source files (for sourcemaps support)', build
    root: "#{fixtures}/build-src-symlink"
    tests: ->
      expect("#{fixtures}/build-src-symlink/build/_src").to.be.a.directory()
      expect("#{fixtures}/build-src-symlink/build/_src").to.be.a.symlink()
      expect("#{fixtures}/build-src-symlink/build/_src/_source").to.be.a.file()


  it 'should copy JavaScript, CSS and unknown files', build
    root: "#{fixtures}/build-copy"
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
    tests: ->
      expect("#{fixtures}/build-coffeescript/build/coffeescript.js").to.have.content """
        (function() {
          console.log('JavaScript');

        }).call(this);\n
      """


  it 'should compile SASS files', build
    root: "#{fixtures}/build-sass"
    tests: ->
      expect("#{fixtures}/build-sass/build/sass.css").to.have.content """
        .main-red,
        .also-red {
          color: red;
        }
      """


  it 'should skip files starting with an underscore', build
    root: "#{fixtures}/build-underscores"
    tests: ->
      expect("#{fixtures}/build-underscores/_vars.scss").not.to.be.a.path()
      expect("#{fixtures}/build-underscores/_vars.css").not.to.be.a.path()
      expect("#{fixtures}/build-underscores/_ignored.coffee").not.to.be.a.path()
      expect("#{fixtures}/build-underscores/_ignored.js").not.to.be.a.path()


  #----------------------------------------
  # Compass
  #----------------------------------------

  it 'should use relative paths for Compass URL helpers', build
    root: "#{fixtures}/build-compass-urls"
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
    tests: ->
      expect("#{fixtures}/build-compass-inline/build/inline.css").to.have.content """
        .inlineImage {
          background: url('data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAQAIBRAA7');
        }
      """


 it 'should support Compass sprites', build
    root: "#{fixtures}/build-compass-sprites"
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
    tests: ->
      expect("#{fixtures}/build-symlink-files/build/file.txt").to.be.a.file()
      expect("#{fixtures}/build-symlink-files/build/file.txt").not.to.be.a.symlink()
      expect("#{fixtures}/build-symlink-files/build/symlink.txt").to.be.a.file()
      expect("#{fixtures}/build-symlink-files/build/symlink.txt").not.to.be.a.symlink()


  it 'should convert symlinks to directories to regular directories', build
    root: "#{fixtures}/build-symlink-dirs"
    tests: ->
      expect("#{fixtures}/build-symlink-dirs/build/orig").to.be.a.directory()
      expect("#{fixtures}/build-symlink-dirs/build/orig").not.to.be.a.symlink()
      expect("#{fixtures}/build-symlink-dirs/build/orig/file.txt").to.be.a.file()
      expect("#{fixtures}/build-symlink-dirs/build/symlink").to.be.a.directory()
      expect("#{fixtures}/build-symlink-dirs/build/symlink").not.to.be.a.symlink()
      expect("#{fixtures}/build-symlink-dirs/build/symlink/file.txt").to.be.a.file()


  it 'should detect infinite symlink loops and skip them with an error message', build
   root: "#{fixtures}/build-symlink-loop"
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
    tests: ->
      expect("#{fixtures}/build-combine-js/build/combine.js").to.have.content """
        f1();

        (function() {
          f2();

        }).call(this);\n
      """


  it 'should combine the content of *.css/ directories', build
    root: "#{fixtures}/build-combine-css"
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
    tests: ->
      expect("#{fixtures}/build-combine-other/build/combine.other").to.be.a.directory()
      expect("#{fixtures}/build-combine-other/build/combine.other/sample.txt").to.be.a.file()


  it 'should detect infinite symlink loops in combined directories and skip them with an error message', build
   root: "#{fixtures}/build-combine-loop"
   tests: ->
     expect("#{fixtures}/build-combine-loop/build/combine.css").to.have.content """
       body {
         color: red;
       }
     """


  #----------------------------------------
  # YAML imports
  #----------------------------------------

  it 'should import JavaScript files listed in a YAML file', build
    root: "#{fixtures}/build-yaml-js"
    tests: ->
      expect("#{fixtures}/build-yaml-js/build/import.js").to.have.content """
        f1();

        (function() {
          f2();

        }).call(this);\n
      """


  it 'should import CSS files listed in a YAML file', build
    root: "#{fixtures}/build-yaml-css"
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


  it 'should not attempt to import files from other YAML files', build
    root: "#{fixtures}/build-yaml-other"
    tests: ->
      expect("#{fixtures}/build-yaml-other/build/import.txt").not.to.be.a.path()
      expect("#{fixtures}/build-yaml-other/build/import.txt.yaml").to.be.a.file()


  it 'should skip imports outside the source directory in YAML files', build
    root: "#{fixtures}/build-yaml-error"
    tests: ->
      expect("#{fixtures}/build-yaml-error/build/import.js").to.have.content """
        f1();\n
        f2();\n
      """


  it 'should import files listed in a YAML file inside a combined directory', build
    root: "#{fixtures}/build-yaml-combine"
    tests: ->
      expect("#{fixtures}/build-yaml-combine/build/combine.js").to.have.content """
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
    tests: ->
      expect("#{fixtures}/build-bower-symlink/build/_bower").to.be.a.symlink()
      expect("#{fixtures}/build-bower-symlink/build/_bower").to.be.a.directory()
      expect("#{fixtures}/build-bower-symlink/build/_bower/bower.txt").to.be.a.file()


  it 'should not create a symlink if the bower target directory does not exist', build
    root: "#{fixtures}/build-bower-missing"
    config:
      bower: 'bower_components/'
    tests: ->
      expect("#{fixtures}/build-bower-missing/build/_bower").not.to.be.a.symlink()
      expect("#{fixtures}/build-bower-missing/build/_bower").not.to.be.a.path()


  it 'should not create a symlink to bower_components/ if set to false', build
    root: "#{fixtures}/build-bower-disabled"
    config:
      bower: false
    tests: ->
      expect("#{fixtures}/build-bower-disabled/build/_bower").not.to.be.a.symlink()
      expect("#{fixtures}/build-bower-disabled/build/_bower").not.to.be.a.path()


  #----------------------------------------
  # URL rewriting
  #----------------------------------------
  # For full tests see UrlRewriter.coffee - this just checks they are applied correctly

  it 'should rewrite relative URLs in symlinked files', build
    root: "#{fixtures}/build-rewrite-symlink"
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
    tests: ->
      expect("#{fixtures}/build-rewrite-invalid/build/invalid-url.css").to.have.content """
        body {
          background: url(invalid.gif);
        }
      """


  #----------------------------------------
  # Miscellaneous
  #----------------------------------------

  it 'should put cache files in .awe/ and create a .gitignore file', build
    root: "#{fixtures}/build-cache"
    tests: ->
      expect("#{fixtures}/build-cache/.awe/sass-cache").to.be.a.directory()
      expect("#{fixtures}/build-cache/.awe/.gitignore").to.be.a.file()


  it "should display an error and not create the build directory if the source directory doesn't exist", build
    root: "#{fixtures}/build-src-missing"
    tests: ->
      expect("#{fixtures}/build-src-missing/build").not.to.be.a.path()
