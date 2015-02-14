expect          = require('chai').expect
config          = require('../lib-build/config')
ConfigError     = require('../lib-build/errors').ConfigError
normaliseConfig = require('../lib-build/normaliseConfig')


expectConfigError = (error, config) ->
  expect(-> normaliseConfig(config)).to.throw(ConfigError, error)


describe 'normaliseConfig()', ->

  # No errors
  it 'should succeed when run normally', ->
    normaliseConfig
      ASSETS:
        test:
          src:  'assets/src/'
          dest: 'assets/build/'


  # Top-level error checking
  it 'should error when the top-level is not an object', ->
    expectConfigError 'Root must be an object (actual type is string)', 'Not an object'


  it 'should error when the top-level is an empty object', ->
    expectConfigError 'File is empty', {}


  it 'should error when the top-level is an empty string', ->
    expectConfigError 'File is empty', ''


  it 'should error when an unknown top-level setting is given', ->
    expectConfigError "Unknown setting 'unknown'",
      unknown: true


  it 'should be case-sensitive', ->
    expectConfigError "Unknown setting 'assets'",
      assets:
        test:
          src:  'assets/src/'
          dest: 'assets/build/'


  # Asset group
  it 'should error when the asset group is not an object', ->
    expectConfigError "Setting 'ASSETS.test' must be an object (actual type is string)",
      ASSETS:
        test: 'Not an object'


  it 'should error when the asset group is an array', ->
    expectConfigError "Setting 'ASSETS.test' must be an object (actual type is array)",
      ASSETS:
        test: [
          'Not an object'
        ]


  it 'should validate asset group names', ->
    expectConfigError "Invalid group name 'abc#def' in ASSETS (a-z, 0-9 only)",
      ASSETS:
        'abc#def':
          src:  'assets/src/'
          dest: 'assets/build/'


  it 'should validate asset group option names', ->
    expectConfigError "Unknown setting 'unknown' in ASSETS.test",
      ASSETS:
        test:
          src:     'assets/src/'
          dest:    'assets/build/'
          unknown: true


  # src
  it 'should require src setting for asset group', ->
    expectConfigError "Missing required setting 'src' in ASSETS.test",
      ASSETS:
        test:
          dest: 'assets/build/'


  it 'should require string value for src in asset group', ->
    expectConfigError "Setting 'ASSETS.test.src' must be a string (actual type is boolean)",
      ASSETS:
        test:
          src:  false
          dest: 'assets/build/'


  # dest
  it 'should require dest setting for asset group', ->
    expectConfigError "Missing required setting 'dest' in ASSETS.test",
      ASSETS:
        test:
          src: 'assets/src/'


  it 'should require string value for dest in asset group', ->
    expectConfigError "Setting 'ASSETS.test.dest' must be a string (actual type is boolean)",
      ASSETS:
        test:
          src:  'assets/src/'
          dest: false


  # bower
  it 'should set default value for bower', ->
    normaliseConfig config =
      ASSETS:
        test:
          src:  'assets/src/'
          dest: 'assets/build/'

    expect(config.ASSETS.test.bower).to.be.false

    normaliseConfig config =
      ASSETS:
        test:
          src:   'assets/src/'
          dest:  'assets/build/'
          bower: 'bower_components/'

    expect(config.ASSETS.test.bower).to.equal 'bower_components/'


  # autoprefixer
  it 'should set default value for autoprefixer', ->
    normaliseConfig config =
      ASSETS:
        test:
          src:  'assets/src/'
          dest: 'assets/build/'

    expect(config.ASSETS.test.autoprefixer).to.be.false

    normaliseConfig config =
      ASSETS:
        test:
          src:          'assets/src/'
          dest:         'assets/build/'
          autoprefixer: true

    expect(config.ASSETS.test.autoprefixer).to.be.true
