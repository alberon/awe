expect = require('chai').expect
params = require('../lib-build/params')

describe 'params.commands ', ->

  it 'should map commands to modules', ->
    expect(params.commands).to.contain
      build: 'cmd-build'
      watch: 'cmd-watch'


describe 'params.synonyms', ->

  it 'should map synonyms to primary commands', ->
    expect(params.synonyms).to.contain
      b: 'build'
      w: 'watch'

describe 'params.parse()', ->

  # Shorthand to make tests more readable
  parse = (args...) -> params.parse(args)

  it 'should parse regular commands', ->
    expect(parse('build')).to.deep.equal
      name:   'build'
      module: 'cmd-build'
      args:   []

  it 'should pass remaining parameters unchanged', ->
    expect(parse('build', '-h', 'a', 'b', '--', 'c')).to.deep.equal
      name:   'build'
      module: 'cmd-build'
      args:   ['-h', 'a', 'b', '--', 'c']

  it 'should support shorthand commands', ->
    expect(parse('b', 'a', 'b')).to.deep.equal
      name:   'build'
      module: 'cmd-build'
      args:   ['a', 'b']

  it 'should support -v global option', ->
    expect(parse('-v')).to.deep.equal
      name:   'version'
      module: 'cmd-version'
      args:   []

  it 'should support --version global option', ->
    expect(parse('--version')).to.deep.equal
      name:   'version'
      module: 'cmd-version'
      args:   []

  it 'should support -h global option', ->
    expect(parse('-h', 'build')).to.deep.equal
      name:   'help'
      module: 'cmd-help'
      args:   ['build']

  it 'should support --help global option', ->
    expect(parse('--help', 'build')).to.deep.equal
      name:   'help'
      module: 'cmd-help'
      args:   ['build']

  it 'should support -h option after command name', ->
    expect(parse('build', '-h')).to.deep.equal
      name:   'help'
      module: 'cmd-help'
      args:   ['build']

  it 'should support --help option after command name', ->
    expect(parse('build', '--help')).to.deep.equal
      name:   'help'
      module: 'cmd-help'
      args:   ['build']

  it 'should default to watch command', ->
    expect(parse()).to.deep.equal
      name:   'watch'
      module: 'cmd-watch'
      args:   []

  it 'should throw error on unknown global parameter', ->
    expect(-> params.parse(['--invalidparameter', 'build'])).to.throw /Unknown global parameter/

  it 'should throw error on unknown command', ->
    expect(-> params.parse(['invalidcommand'])).to.throw /Unknown command/
