errors = require('../lib-build/errors')
expect = require('chai').expect

# These are so simple there should be no need for them, but it turns out it's
# quite hard to sub-class Error and have it work correctly
describe 'errors.ConfigError', ->

  ConfigError = errors.ConfigError

  it 'should exist', ->
    expect(ConfigError).to.be.a 'function'

  it 'should be instanceof ConfigError', ->
    expect(new ConfigError).to.be.instanceof ConfigError

  it 'should be instanceof Error', ->
    expect(new ConfigError).to.be.instanceof Error

  it 'should contain a message', ->
    expect(new ConfigError('ABC').message).to.equal 'ABC'

  it 'should contain a stack trace', ->
    expect(new ConfigError('ABC').stack).to.be.a 'string'
