css    = require('../lib/util/css')
expect = require('chai').use(require('chai-fs')).expect

describe 'css', ->

  describe '.rewriteUrls()', ->

    # Helper - mark which part of the file would be replaced
    callback = (url) -> "<#{url}>"


    it 'should return CSS without URLs unchanged', ->

      input = """
        body {
          background: red;
        }
      """

      expect(css.rewriteUrls(input, callback)).to.equal input


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

      expect(css.rewriteUrls(input, callback)).to.equal output


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

      expect(css.rewriteUrls(input, callback)).to.equal output


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

      expect(css.rewriteUrls(input, callback)).to.equal output


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

      expect(css.rewriteUrls(input, callback)).to.equal output
