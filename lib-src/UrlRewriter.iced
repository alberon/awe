fs   = require('fs')
path = require('path')
S    = require('string')

# This class is responsible for converting relative URLs in CSS source files to
# the equivalent relative URL in the destination file, taking into account
# combined files, symlinks and Bower. It is NOT responsible for parsing the CSS.
# It is a class because we expect there to be more than one URL to rewrite in
# each file, and this way we only have to resolve and validate the file paths
# once per file. It could potentially be improved by making it reusable across
# multiple files, since the root, srcDir and destDir don't vary.
class UrlRewriter

  constructor: (params) ->

    # Resolve any symlinks in the source files
    @root    = fs.realpathSync(params.root)
    @srcDir  = fs.realpathSync(params.srcDir)
    @srcFile = fs.realpathSync(params.srcFile)

    # Destination files may not exist yet, but we don't care anyway
    @destDir  = params.destDir
    @destFile = params.destFile

    # Bower is optional
    if params.bowerSrc and params.bowerDest
      @bowerSrc  = fs.realpathSync(params.bowerSrc)
      @bowerDest = params.bowerDest
    else
      @bowerSrc  = false
      @bowerDest = false

    # Make sure the parameters are valid, e.g. no symlinks to outside files
    if @srcFile.indexOf(@srcDir) == 0
      # OK
    else if @bowerSrc and @srcFile.indexOf(@bowerSrc) == 0
      # OK
    else
      # Not OK
      if @bowerSrc
        bowerMsg = " or Bower directory '#{@bowerSrc}'"
      else
        bowerMsg = ''

      if @srcFile == params.srcFile
        throw new Error("UrlRewriter: Source file '#{@srcFile}' is not in source directory '#{@srcDir}'" + bowerMsg)
      else
        throw new Error("Source file '#{params.srcFile}' resolves to '#{@srcFile}' which is not in source directory '#{@srcDir}'" + bowerMsg)

    if @destFile.indexOf(@destDir) != 0
      throw new Error("UrlRewriter: Destination file '#{@destFile}' is not in destination directory '#{@destDir}'")

  rewrite: (url) ->
    # Ignore absolute paths and URIs
    if url[0...1] == '/' or url.indexOf(':') > 0
      return url

    # Strip any ?query string or #anchor from the filename - sometimes used for
    # cache-busting and SVG fonts
    file = url
    suffix = ''

    if matches = file.match(/^([^?#]*)([?#].*)$/)
      file = matches[1]
      suffix = matches[2]

    # It's valid to have an URL that only contains an anchor and no file
    # https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/SVG_fonts#Option.3A_Use_CSS_.40font-face
    if !file
      return url

    # Find the destination file
    file = path.resolve(path.dirname(@srcFile), file)

    # Resolve any symlinks, which helpfully also ensures the file exists
    try
      file = fs.realpathSync(file)
    catch e
      if e.code == 'ENOENT'
        throw new Error("Invalid file path: '#{url}' in '#{@_stripRoot(@srcFile)}' (resolves to '#{@_stripRoot(file)}' which was not found)")
      else
        throw e

    # Replace the source directory prefix with the destination directory
    if S(file).startsWith(@srcDir)
      file = @destDir + file.substr(@srcDir.length)
    else if @bowerSrc and S(file).startsWith(@bowerSrc)
      file = @bowerDest + file.substr(@bowerSrc.length)
    else if @bowerSrc
      throw new Error("Invalid file path: '#{url}' in '#{@_stripRoot(@srcFile)}' (resolves to '#{@_stripRoot(file)}' which is outside the source directory '#{@_stripRoot(@srcDir)}' and Bower directory '#{@_stripRoot(@bowerSrc)}')")
    else
      throw new Error("Invalid file path: '#{url}' in '#{@_stripRoot(@srcFile)}' (resolves to '#{@_stripRoot(file)}' which is outside the source directory '#{@_stripRoot(@srcDir)}')")

    # Convert to a relative path
    url = path.relative(path.dirname(@destFile), file)

    return url + suffix

  _stripRoot: (path) =>
    S(path).chompLeft(@root + '/').s

module.exports = UrlRewriter
