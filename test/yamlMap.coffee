expect  = require('chai').expect
path    = require('path')
yamlMap = require('../lib/yamlMap')

fixtures = path.resolve(__dirname, '../fixtures/yaml-map')

describe 'yamlMap()', ->

  it 'should support relative paths', (done) ->
    yamlMap "#{fixtures}/relative.yaml", null, (err, files) ->
      expect(err).to.not.be.ok
      expect(files).to.deep.equal ["#{fixtures}/sample.css"]
      done()


  it 'should support bower paths', (done) ->
    yamlMap "#{fixtures}/bower.yaml", '/bower/', (err, files) ->
      expect(err).to.not.be.ok
      expect(files).to.deep.equal ["/bower/sample.css"]
      done()


  it 'should support multiple files', (done) ->
    yamlMap "#{fixtures}/multiple.yaml", '/bower/', (err, files) ->
      expect(err).to.not.be.ok
      expect(files).to.deep.equal ["#{fixtures}/sample.css", "/bower/sample.css"]
      done()


