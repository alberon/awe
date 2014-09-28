expect         = require('chai').use(require('chai-fs')).expect
rewriteCssUrls = require('../lib/rewriteCssUrls')

describe 'rewriteCssUrls()', ->

  # Helper - mark which part of the file would be replaced
  callback = (url) -> "<#{url}>"


  it 'should return CSS without URLs unchanged', ->

    input = """
      body {
        background: red;
      }
    """

    data = rewriteCssUrls(input, 'sample.css', callback)
    expect(data.code).to.equal input
    expect(data.map).to.be.an 'object'


  it 'should replace url(FILENAME)', ->

    input = """
      body {
        background: url(sample.gif);
      }
    """

    output = """
      body {
        background: url(<sample.gif>);
      }
    """

    data = rewriteCssUrls(input, 'sample.css', callback)
    expect(data.code).to.equal output
    expect(data.map).to.be.an 'object'


  it 'should replace url(\'FILENAME\'), preserving the quotes', ->

    input = """
      body {
        background: url('sample.gif');
      }
    """

    output = """
      body {
        background: url('<sample.gif>');
      }
    """

    data = rewriteCssUrls(input, 'sample.css', callback)
    expect(data.code).to.equal output
    expect(data.map).to.be.an 'object'


  it 'should replace url("FILENAME"), preserving the quotes', ->

    input = """
      body {
        background: url("sample.gif");
      }
    """

    output = """
      body {
        background: url("<sample.gif>");
      }
    """

    data = rewriteCssUrls(input, 'sample.css', callback)
    expect(data.code).to.equal output
    expect(data.map).to.be.an 'object'


  it 'should replace multiple URLs', ->

    input = """
      body {
        background: url(sample1.gif), url(sample2.gif);
        cursor: url('cursor.gif'), auto;
      }
    """

    output = """
      body {
        background: url(<sample1.gif>), url(<sample2.gif>);
        cursor: url('<cursor.gif>'), auto;
      }
    """

    data = rewriteCssUrls(input, 'sample.css', callback)
    expect(data.code).to.equal output
    expect(data.map).to.be.an 'object'


  it 'should ignore commented sections', ->

    input = """
      body {
        /*background: url(sample1.gif), url(sample2.gif);*/
        /*
        cursor: url('cursor.gif'), auto;
        */
      }
    """

    output = """
      body {
        /*background: url(sample1.gif), url(sample2.gif);*/
        /*
        cursor: url('cursor.gif'), auto;
        */
      }
    """

    data = rewriteCssUrls(input, 'sample.css', callback)
    expect(data.code).to.equal output
    expect(data.map).to.be.an 'object'


  it 'should replace URLs in fonts', ->

    input = """
      @font-face {
        src: url(myfont.woff), auto;
      }
    """

    output = """
      @font-face {
        src: url(<myfont.woff>), auto;
      }
    """

    data = rewriteCssUrls(input, 'sample.css', callback)
    expect(data.code).to.equal output
    expect(data.map).to.be.an 'object'
