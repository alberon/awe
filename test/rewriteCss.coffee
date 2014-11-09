expect     = require('chai').use(require('chai-fs')).expect
rewriteCss = require('../lib-build/rewriteCss')

describe 'rewriteCss()', ->

  # Helper - mark which part of the file would be replaced
  callback = (url) -> "<#{url}>"


  it 'should return CSS without URLs unchanged', ->

    input = """
      body {
        background: red;
      }
    """

    data = rewriteCss(input, '', '', rewriteUrls: callback)
    expect(data.css).to.equal input


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

    data = rewriteCss(input, '', '', rewriteUrls: callback)
    expect(data.css).to.equal output


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

    data = rewriteCss(input, '', '', rewriteUrls: callback)
    expect(data.css).to.equal output


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

    data = rewriteCss(input, '', '', rewriteUrls: callback)
    expect(data.css).to.equal output


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

    data = rewriteCss(input, '', '', rewriteUrls: callback)
    expect(data.css).to.equal output


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

    data = rewriteCss(input, '', '', rewriteUrls: callback)
    expect(data.css).to.equal output


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

    data = rewriteCss(input, '', '', rewriteUrls: callback)
    expect(data.css).to.equal output
