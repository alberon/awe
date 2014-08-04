_           = require('lodash')
expect      = require('chai').use(require('chai-fs')).expect
fs          = require('fs')
path        = require('path')
UrlRewriter = require('../lib/util/UrlRewriter')

describe 'UrlRewriter', ->

  fixtures = path.resolve(__dirname, '../fixtures/url-rewriter')

  defaultParams =
    root:      fixtures
    srcDir:    path.join(fixtures, 'src')
    srcFile:   path.join(fixtures, 'src', 'sample.css')
    destDir:   path.join(fixtures, 'dest')
    destFile:  path.join(fixtures, 'dest', 'sample.css')
    bowerSrc:  path.join(fixtures, 'bower_components')
    bowerDest: path.join(fixtures, 'dest' ,'bower_components')

  # Helpers
  create = (params = {}) ->
    _.defaults(params, defaultParams)
    new UrlRewriter(params)

  rewrite = (url, params) ->
    create(params).rewrite(url)


  it 'should return absolute URLs unchanged', ->
    url = 'http://www.google.co.uk/'
    expect(rewrite(url)).to.equal url


  it 'should return data URIs unchanged', ->
    uri = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'
    expect(rewrite(uri)).to.equal uri


  it 'should throw an error if the src. file is outside the src. directory', ->
    params =
      srcFile: path.join(fixtures, 'outside.css')

    expect(-> create(params)).to.throw /not in source directory/


  it 'should throw an error if the dest. file is outside the dest. directory', ->
    params =
      destFile: path.join(fixtures, 'outside.css')

    expect(-> create(params)).to.throw /not in destination directory/


  it 'should return direct mappings unchanged', ->
    expect(rewrite('sample.gif')).to.equal 'sample.gif'


  it 'should rewrite paths in compiled directories', ->
    params =
      srcFile: path.join(fixtures, 'src', 'compiled.css', 'source.css')

    expect(rewrite('../sample.gif', params)).to.equal 'sample.gif'


  it 'should rewrite paths in symlinked files relative to the original file', ->
    params =
      srcFile: path.join(fixtures, 'src', 'symlink', 'sample.css') # Real path is src/sample.css
      destFile: path.join(fixtures, 'dest', 'symlink', 'sample.css')

    expect(rewrite('sample.gif', params)).to.equal '../sample.gif'


  it 'should rewrite paths pointing to bower_components/', ->
    expect(rewrite('../bower_components/sample.gif')).to.equal 'bower_components/sample.gif'


  it 'should rewrite paths in symlinks to bower_components/', ->
    params =
      srcFile: path.join(fixtures, 'src', 'bower.css') # Real path is bower_components/bower.css

    expect(rewrite('sample.gif', params)).to.equal 'bower_components/sample.gif'


  it 'should throw an error if the target file is outside the src. and Bower directories', ->
    expect(-> rewrite('../outside.gif')).to.throw /Invalid file path/


  it 'should throw an error if the target file is not found', ->
    expect(-> rewrite('invalid.gif')).to.throw /Invalid file path/


  it 'should support projects with no bower_components/ directory', ->

    params =
      bowerSrc: null
      bowerDest: null

    expect(rewrite('sample.gif')).to.equal 'sample.gif'
    expect(-> rewrite('invalid.gif')).to.throw /Invalid file path/

  it 'should support ?query strings', ->
    expect(rewrite('sample.gif?query')).to.equal 'sample.gif?query'

  it 'should support #anchors', ->
    expect(rewrite('sample.gif#anchor')).to.equal 'sample.gif#anchor'

  it 'should support plain #anchors with no filename (for SVG fonts)', ->
    expect(rewrite('#anchor')).to.equal '#anchor'
