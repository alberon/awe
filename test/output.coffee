expect = require('chai').expect
output = require('../lib/output')

describe 'output', ->

  # Just some basic tests that the right methods exist
  it 'should have a .building() method', ->
    expect(output.building).to.be.a('function')

  it 'should have a .compiled() method', ->
    expect(output.compiled).to.be.a('function')

  it 'should have a .copied() method', ->
    expect(output.copied).to.be.a('function')

  it 'should have a .created() method', ->
    expect(output.created).to.be.a('function')

  it 'should have an .emptied() method', ->
    expect(output.emptied).to.be.a('function')

  it 'should have an .error() method', ->
    expect(output.error).to.be.a('function')

  it 'should have a .finished() method', ->
    expect(output.finished).to.be.a('function')

  it 'should have a .generated() method', ->
    expect(output.generated).to.be.a('function')

  it 'should have a .line() method', ->
    expect(output.line).to.be.a('function')

  it 'should have a .modified() method', ->
    expect(output.modified).to.be.a('function')

  it 'should have a .symlink() method', ->
    expect(output.symlink).to.be.a('function')

  it 'should have a .warning() method', ->
    expect(output.warning).to.be.a('function')

  it 'should have a .watching() method', ->
    expect(output.watching).to.be.a('function')

  it 'should have a .disable() method', ->
    expect(output.disable).to.be.a('function')

  it 'should have an .enable() method', ->
    expect(output.enable).to.be.a('function')
