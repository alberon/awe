expect = require('chai').use(require('chai-fs')).expect
fs     = require('fs')
path   = require('path')
rmdir  = require('rimraf').sync
spawn  = require('child_process').spawn

#================================================================================
# Note: This is more of an *integration* test than a *unit* test - it actually
# runs 'awe' which runs 'compass' and compiles the CoffeeScript, so it takes
# several seconds. Any functionality that can be extracted into another file and
# tested independently should be.
#================================================================================

bin = path.resolve(__dirname, '../bin/awe')

describe 'assets - build (regular)', ->

  fixtures = path.resolve(__dirname, '../fixtures/build-test')
  awedir   = path.join(fixtures, '.awe')
  build    = path.join(fixtures, 'build')
  build1   = path.join(build, '1')
  build2   = path.join(build, '2')
  build3   = path.join(build, '3')

  before ->
    rmdir(awedir)
    rmdir(build)


  it 'should build successfully', (done) ->
    @timeout 10000
    spawn(bin, ['build'], cwd: fixtures, stdio: ['ignore', 'ignore', 2]).on 'exit', (exitcode) ->
      expect(exitcode).to.equal 0
      done()


  it 'should create a symlink to the source files for sourcemaps support', ->
    expect("#{build1}/_src").to.be.a.directory()
    expect(fs.lstatSync("#{build1}/_src").isSymbolicLink()).to.be.true
    expect("#{build1}/_src/coffeescript.coffee").to.be.a.file()


  it 'should create a symlink to bower_components/', ->
    expect("#{build1}/_bower").to.be.a.directory()
    expect(fs.lstatSync("#{build1}/_bower").isSymbolicLink()).to.be.true


  it 'should not create a symlink to bower_components/ if set to false', ->
    expect("#{build2}/_bower").to.not.be.a.path()


  it 'should support custom bower directories/', ->
    expect("#{build3}/bower-custom.css").to.be.a.file()
    expect("#{build3}/_bower").to.be.a.directory()
    expect(fs.lstatSync("#{build3}/_bower").isSymbolicLink()).to.be.true
    expect("#{build3}/_bower/bower-custom.css").to.be.a.file()


  it 'should compile CoffeeScript files', ->
    expect("#{build1}/coffeescript.js").to.have.content """
      (function() {
        console.log('JavaScript');

      }).call(this);\n
    """


  it 'should compile SASS files', ->
    expect("#{build1}/sass.css").to.have.content """
      .main-red,
      .also-red {
        color: red;
      }
    """


  it 'should copy other files directly', ->
    expect("#{build1}/javascript.js").to.have.content """
      console.log('JavaScript');\n
    """

    expect("#{build1}/stylesheet.css").to.have.content """
      .red {
        color: red;
      }
    """

    expect("#{build1}/unknown.file").to.have.content """
      Unknown\n
    """


  it 'should compile the second assets group to a separate directory', ->
    expect("#{build2}/coffeescript2.js").to.be.a.file()
    expect("#{build2}/sass2.css").to.be.a.file()
    expect("#{build2}/unknown2.file").to.be.a.file()


  it 'should ignore files starting with an underscore', ->
    expect("#{build1}/_vars.scss").to.not.be.a.path()
    expect("#{build1}/_vars.css").to.not.be.a.path()
    expect("#{build1}/_ignored.coffee").to.not.be.a.path()
    expect("#{build1}/_ignored.js").to.not.be.a.path()


  it 'should rewrite relative URLs in symlinked files', ->
    expect("#{build1}/sample.css").to.have.content """
      body {
        background: url(_bower/sample.gif);
      }
    """


  it 'should combine the content of *.js/ directories', ->
    expect("#{build1}/combined.js").to.have.content """
      f1();

      (function() {
        f2();

      }).call(this);\n
    """


  it 'should combine the content of *.css/ directories and rewrite URLs', ->
    expect("#{build1}/combined.css").to.have.content """
      .css {
        background: url(_bower/sample.gif);
        color: red;
      }
      .scss {
        background: url(_bower/sample.gif);
        color: green;
      }
    """


  it 'should warn about invalid filenames in CSS, but build anyway', ->
    # TODO: Not currently testing the warning message, just that it builds OK
    expect("#{build1}/has-invalid-url.css").to.have.content """
      .css {
        background: url(invalid.gif);
      }
    """


  it 'should use relative paths for Compass URL helpers', ->
    expect("#{build1}/compass/urls.css").to.have.content """
      .imageUrl {
        background: url('../img/blank.gif');
      }

      @font-face {
        font-family: myfont;
        src: url('../fonts/myfont.woff');
      }
    """


  it 'should support the Compass inline-image() helper', ->
    expect("#{build1}/compass/inline.css").to.have.content """
      .inlineImage {
        background: url('data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAQAIBRAA7');
      }
    """


  it 'should support Compass sprites', ->
    content = fs.readFileSync("#{build1}/compass/sprite.css", encoding: 'utf8')
    expect(content).to.match /\.icons-sprite,\n\.icons-icon1,\n\.icons-icon2 {/
    expect(content).to.match /background-image: url\('\.\.\/_generated\/icons-[^']+\.png'\);/

    icon = content.match(/background-image: url\('\.\.\/_generated\/(icons-[^']+\.png)'\);/)[1]
    expect("#{build1}/_generated/#{icon}").to.be.a.file()


  it 'should add cross-browser prefixes', ->
    expect("#{build1}/autoprefixer.css").to.have.content """
      body {
        -webkit-transition: -webkit-transform 1s;
                transition: transform 1s;
      }
    """


  it 'should put cache files in .awe/ and create a .gitignore file', ->
    expect("#{awedir}/sass-cache").to.be.a.directory()
    expect("#{awedir}/.gitignore").to.be.a.file()


describe 'assets - build (config missing)', ->
  fixtures = path.resolve(__dirname, '../fixtures/config-missing')


  it 'should exit with code 1', (done) ->
    spawn(bin, ['build'], cwd: fixtures).on 'exit', (exitcode) ->
      expect(exitcode).to.equal 1
      done()
