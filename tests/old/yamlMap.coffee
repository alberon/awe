expect  = require('chai').expect
path    = require('path')
yamlMap = require('../lib-build/yamlMap')


normalise = (config) ->
  yamlMap.normalise(config, '/FILEPATH', '/BOWERPATH', (message) -> throw new Error(message))

expectNormaliseError = (error, config) ->
  expect(-> normalise(config)).to.throw(error)


describe 'yamlMap.normalise()', ->
  it 'should support relative paths', ->
    files = normalise [
      'sample1.css'
      'sample2.css'
    ]

    expect(files).to.deep.equal [
      '/FILEPATH/sample1.css'
      '/FILEPATH/sample2.css'
    ]


  it 'should support bower paths', ->
    files = normalise [
      {bower: 'sample1.css'}
      {bower: 'sample2.css'}
    ]

    expect(files).to.deep.equal [
      '/BOWERPATH/sample1.css'
      '/BOWERPATH/sample2.css'
    ]


  it 'should support mixed sources', ->
    files = normalise [
      'sample.css'
      {bower: 'sample.css'}
    ]

    expect(files).to.deep.equal [
      '/FILEPATH/sample.css'
      '/BOWERPATH/sample.css'
    ]


  it "should error when the root is null", ->
    expectNormaliseError 'Does not contain an array of files', null


  it "should error when there is an entry that is null", ->
    expectNormaliseError 'Invalid import path: should be a string or object:\nnull', [null]


  it "should error when there is an entry with no 'bower' key", ->
    expectNormaliseError 'Invalid import path: object doesn\'t have a \'bower\' key:\n{"invalid":"file"}',
      [invalid: 'file']


describe 'yamlMap()', ->

  fixtures = path.resolve(__dirname, '../fixtures/yaml-map')

  it 'should support relative paths', (done) ->
    yamlMap "#{fixtures}/relative.yaml", null, (err, files) ->
      expect(err).to.not.be.ok
      expect(files).to.deep.equal [
        "#{fixtures}/sample.css"
      ]
      done()


  it 'should support bower paths', (done) ->
    yamlMap "#{fixtures}/bower.yaml", '/bower/', (err, files) ->
      expect(err).to.not.be.ok
      expect(files).to.deep.equal [
        "/bower/sample.css"
      ]
      done()


  it 'should support multiple files', (done) ->
    yamlMap "#{fixtures}/multiple.yaml", '/bower/', (err, files) ->
      expect(err).to.not.be.ok
      expect(files).to.deep.equal [
        "#{fixtures}/sample.css"
        "/bower/sample.css"
      ]
      done()
