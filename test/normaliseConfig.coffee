expect          = require('chai').expect
config          = require('../lib/config')
ConfigError     = require('../lib/errors').ConfigError
normaliseConfig = require('../lib/normaliseConfig')


expectConfigError = (error, config) ->
  expect(-> normaliseConfig(config)).to.throw(ConfigError, error)


describe 'normaliseConfig()', ->

  # No errors
  it 'should succeed when run normally', ->
    normaliseConfig
      assets:
        src:  'assets/src/'
        dest: 'assets/build/'


  # Top-level error checking
  it 'should error when the top-level is not an object', ->
    expectConfigError 'Root must be an object (actual type is string)', 'Not an object'


  it 'should error when the top-level is an empty object', ->
    expectConfigError 'File is empty', {}


  it 'should error when the top-level is an empty string', ->
    expectConfigError 'File is empty', ''


  # Asset group error checking
  it 'should error when the asset group is not an object', ->
    expectConfigError "Setting 'assets' must be an object (actual type is string)",
      assets: 'Not an object'


  it 'should error when the asset group is an array', ->
    expectConfigError "Setting 'assets' must be an object (actual type is array)",
      assets: [
        'Not an object'
      ]


  it 'should validate asset group names', ->
    expectConfigError "Invalid group name 'abc#def'",
      'abc#def':
        src:  'assets/src/'
        dest: 'assets/build/'


  it 'should validate asset group option names', ->
    expectConfigError "Unknown setting 'unknown' in assets",
      assets:
        src:  'assets/src/'
        dest: 'assets/build/'
        unknown: true


  it 'should be case-sensitive', ->
    expectConfigError "Unknown setting 'Src'",
      assets:
        Src:  'assets/src/'
        dest: 'assets/build/'


  # src
  it 'should require src setting for asset group', ->
    expectConfigError "Missing required setting 'src' in assets",
      assets:
        dest: 'assets/build/'


  it 'should require string value for src in asset group', ->
    expectConfigError "Setting 'assets.src' must be a string (actual type is boolean)",
      assets:
        src: false
        dest: 'assets/build/'


  # dest
  it 'should require dest setting for asset group', ->
    expectConfigError "Missing required setting 'dest' in assets",
      assets:
        src:  'assets/src/'


  it 'should require string value for dest in asset group', ->
    expectConfigError "Setting 'assets.dest' must be a string (actual type is boolean)",
      assets:
        src:  'assets/src/'
        dest: false


  # autoprefixer
  it 'should set default value for autoprefixer', ->
    normaliseConfig config =
      assets:
        src:  'assets/src/'
        dest: 'assets/build/'

    expect(config.assets.autoprefixer).to.be.true

    normaliseConfig config =
      assets:
        src:  'assets/src/'
        dest: 'assets/build/'
        autoprefixer: false

    expect(config.assets.autoprefixer).to.be.false


  # bower
  it 'should set default value for bower', ->
    normaliseConfig config =
      assets:
        src:  'assets/src/'
        dest: 'assets/build/'

    expect(config.assets.bower).to.equal 'bower_components/'

    normaliseConfig config =
      assets:
        src:  'assets/src/'
        dest: 'assets/build/'
        bower: false

    expect(config.assets.bower).to.be.false


  # sourcemaps
  it 'should set default value for sourcemaps', ->
    normaliseConfig config =
      assets:
        src:  'assets/src/'
        dest: 'assets/build/'

    expect(config.assets.sourcemaps).to.be.true

    normaliseConfig config =
      assets:
        src:        'assets/src/'
        dest:       'assets/build/'
        sourcemaps: false

    expect(config.assets.sourcemaps).to.be.false


  # warning file
  it 'should set default value for warning file', ->
    normaliseConfig config =
      assets:
        src:  'assets/src/'
        dest: 'assets/build/'

    expect(config.assets['warning file']).to.be.true

    normaliseConfig config =
      assets:
        src:        'assets/src/'
        dest:       'assets/build/'
        'warning file': false

    expect(config.assets['warning file']).to.be.false
