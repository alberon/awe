autoprefixer = require('autoprefixer-core')
path         = require('path')
postcss      = require('postcss')


urlRegex = ///
    (url\() # url(
    (['"]?) # open quote, optional
    (.*?)   # URL - ungreedy
    \2      # close quote
    (\))    # )
///g


module.exports = (content, srcFile, destFile, settings = {}) ->

    processors = postcss()

    # Rewrite URLs
    if settings.rewriteUrls
        processors.use (css) ->
            css.eachDecl (decl) ->
                decl.value = decl.value.replace urlRegex, (matches, pre, quote, url, post) ->
                    pre + quote + settings.rewriteUrls(url) + quote + post

    # Autoprefixer
    if settings.autoprefixer
        processors.use(autoprefixer)

    # Source map
    if settings.sourcemap
        map = { prev: settings.prevSourcemap }
    else
        map = false

    processors.process(content, from: srcFile, to: path.basename(destFile), map: map)
