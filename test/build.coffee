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

describe 'build', ->
  bin = path.resolve(__dirname, '../bin/awe')

  describe '(regular)', ->
    fixtures = path.resolve(__dirname, '../fixtures/build-test')
    awedir   = path.join(fixtures, '.awe')
    dist     = path.join(fixtures, 'dist')
    dist1    = path.join(dist, '1')
    dist2    = path.join(dist, '2')

    before ->
      rmdir(awedir)
      rmdir(dist)


    it 'should build successfully', (done) ->
      @timeout 10000
      spawn(bin, ['build'], cwd: fixtures, stdio: ['ignore', 'ignore', 2]).on 'exit', (exitcode) ->
        expect(exitcode).to.equal 0
        done()


    it 'should create a symlink to the source files for sourcemaps support', ->
      expect("#{dist1}/_src").to.be.a.directory()
      expect(fs.lstatSync("#{dist1}/_src").isSymbolicLink()).to.be.true
      expect("#{dist1}/_src/coffeescript.coffee").to.be.a.file()


    it 'should create a symlink to bower_components/', ->
      expect("#{dist1}/_bower").to.be.a.directory()
      expect(fs.lstatSync("#{dist1}/_bower").isSymbolicLink()).to.be.true


    it 'should compile CoffeeScript files', ->
      expect("#{dist1}/coffeescript.js").to.have.content """
        (function() {
          console.log('JavaScript');

        }).call(this);\n
      """


    it 'should compile SASS files', ->
      expect("#{dist1}/sass.css").to.have.content """
        .main-red, .also-red {
          color: red;
        }\n
      """


    it 'should copy other files directly', ->
      expect("#{dist1}/javascript.js").to.have.content """
        console.log('JavaScript');\n
      """

      expect("#{dist1}/stylesheet.css").to.have.content """
        .red {
          color: red;
        }\n
      """

      expect("#{dist1}/unknown.file").to.have.content """
        Unknown\n
      """


    it 'should compile the second assets group to a separate directory', ->
      expect("#{dist2}/coffeescript2.js").to.be.a.file()
      expect("#{dist2}/sass2.css").to.be.a.file()
      expect("#{dist2}/unknown2.file").to.be.a.file()


    it 'should ignore files starting with an underscore', ->
      expect("#{dist1}/_vars.scss").to.not.be.a.path()
      expect("#{dist1}/_vars.css").to.not.be.a.path()
      expect("#{dist1}/_ignored.coffee").to.not.be.a.path()
      expect("#{dist1}/_ignored.js").to.not.be.a.path()


    it 'should rewrite relative URLs in symlinked files', ->
      expect("#{dist1}/sample.css").to.have.content """
        body {
          background: url(_bower/sample.gif);
        }\n
      """


    it 'should combine the content of *.js/ directories', ->
      expect("#{dist1}/combined.js").to.have.content """
        f1();

        (function() {
          f2();

        }).call(this);\n
      """


    it 'should combine the content of *.css/ directories and rewrite URLs', ->
      expect("#{dist1}/combined.css").to.have.content """
        .css {
          background: url(_bower/sample.gif);
          color: red;
        }

        .scss {
          background: url(_bower/sample.gif);
          color: green;
        }\n
      """


    it 'should warn about invalid filenames in CSS, but build anyway', ->
      # TODO: Not currently testing the warning message, just that it builds OK
      expect("#{dist1}/has-invalid-url.css").to.have.content """
        .css {
          background: url(invalid.gif);
        }\n
      """


    it 'should use relative paths for Compass URL helpers', ->
      expect("#{dist1}/compass/urls.css").to.have.content """
        .imageUrl {
          background: url('../img/blank.gif');
        }

        @font-face {
          font-family: myfont;
          src: url('../fonts/myfont.woff');
        }\n
      """


    it 'should support the Compass inline-image() helper', ->
      expect("#{dist1}/compass/inline.css").to.have.content """
        .inlineImage {
          background: url('data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAQAIBRAA7');
        }\n
      """


    it 'should support Compass sprites', ->
      content = fs.readFileSync("#{dist1}/compass/sprite.css", encoding: 'utf8')
      expect(content).to.match /\.icons-sprite, \.icons-icon1, \.icons-icon2 {/
      expect(content).to.match /background-image: url\('\.\.\/_generated\/icons-[^']+\.png'\);/

      icon = content.match(/background-image: url\('\.\.\/_generated\/(icons-[^']+\.png)'\);/)[1]
      expect("#{dist1}/_generated/#{icon}").to.be.a.file()


    it 'should put cache files in .awe/ and create a .gitignore file', ->
      expect("#{awedir}/sass-cache").to.be.a.directory()
      expect("#{awedir}/.gitignore").to.be.a.file()


  describe '(config missing)', ->
    fixtures = path.resolve(__dirname, '../fixtures/build-config-missing')


    it 'should exit with code 1', (done) ->
      spawn(bin, ['build'], cwd: fixtures).on 'exit', (exitcode) ->
        expect(exitcode).to.equal 1
        done()
