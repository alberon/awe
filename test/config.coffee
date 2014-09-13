config = require('../lib/config')
expect = require('chai').expect
path   = require('path')


describe 'config.load()', ->

  it 'config.loaded should be false', ->
    expect(config.loaded).to.be.false

  it 'load should succeed', (cb) ->
    config.cwd = path.resolve(__dirname, '../fixtures/config-test')
    config.load(cb)

  it 'config.loaded be true', ->
    expect(config.loaded).to.be.true


describe 'config.data', ->

  it 'should contain the parsed, normalised config data', ->
    expect(config.data).to.deep.equal
      assets:
        theme:
          src: 'assets/src/'
          dest: 'assets/build/'
          bower: true
          autoprefixer: false
