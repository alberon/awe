expect          = require('chai').expect
normaliseConfig = require('../lib/normaliseConfig')


expectConfigError = (error, config) ->
  expect(-> normaliseConfig(config)).to.throw(normaliseConfig.ConfigError, error)


describe 'normaliseConfig()', ->

  it 'should have an error class', ->
    expect(normaliseConfig.ConfigError).to.be.a 'function'


  it 'should succeed when run normally', ->
    normaliseConfig
      assets:
        theme:
          src:  'assets/src/'
          dest: 'assets/build/'


  it 'should error when the top-level is not an object', ->
    expectConfigError 'Config root must be an object (type is string)', 'Not an object'


  it 'should error when the top-level is an empty object', ->
    expectConfigError 'Config file is empty', {}


  it 'should error when the top-level is an empty string', ->
    expectConfigError 'Config file is empty', ''


  it 'should error when an unknown top-level setting is given', ->
    expectConfigError "Unknown setting 'unknown' in (root)",
      unknown: true


  it 'should be case-sensitive', ->
    expectConfigError "Unknown setting 'Assets' in (root)",
      Assets:
        theme:
          src:  'assets/src/'
          dest: 'assets/build/'


  it 'should validate asset group names', ->
    expectConfigError "Invalid group name 'abc#def' in assets",
      assets:
        'abc#def':
          src:  'assets/src/'
          dest: 'assets/build/'


  it 'should validate asset option names', ->
    expectConfigError "Unknown setting 'unknown' in assets.theme",
      assets:
        theme:
          src:  'assets/src/'
          dest: 'assets/build/'
          unknown: true


  it 'should set default value for autoprefixer', ->
    normaliseConfig config =
      assets:
        theme:
          src:  'assets/src/'
          dest: 'assets/build/'

    expect(config.assets.theme.autoprefixer).to.be.false

    normaliseConfig config =
      assets:
        theme:
          src:  'assets/src/'
          dest: 'assets/build/'
          autoprefixer: true

    expect(config.assets.theme.autoprefixer).to.be.true


  it 'should set default value for bower', ->
    normaliseConfig config =
      assets:
        theme:
          src:  'assets/src/'
          dest: 'assets/build/'

    expect(config.assets.theme.bower).to.equal 'bower_components/'

    normaliseConfig config =
      assets:
        theme:
          src:  'assets/src/'
          dest: 'assets/build/'
          bower: false

    expect(config.assets.theme.bower).to.be.false


  it 'should require src setting for asset group', ->
    expectConfigError "Missing required setting 'src' in assets.theme",
      assets:
        theme:
          dest: 'assets/build/'


  it 'should require string value for src in asset group', ->
    expectConfigError "Setting 'src' must be a string in assets.theme (type is boolean)",
      assets:
        theme:
          src: false
          dest: 'assets/build/'


  it 'should require dest setting for asset group', ->
    expectConfigError "Missing required setting 'dest' in assets.theme",
      assets:
        theme:
          src:  'assets/src/'


  it 'should require string value for dest in asset group', ->
    expectConfigError "Setting 'dest' must be a string in assets.theme (type is boolean)",
      assets:
        theme:
          src:  'assets/src/'
          dest: false
