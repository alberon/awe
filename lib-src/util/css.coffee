exports.rewriteUrls = (content, callback) ->

  content.replace ///
    (url\()  # url(
    (['"]?)  # open quote, optional
    (.*?)    # URL - ungreedy
    \2       # close quote
    (\))     # close bracket
  ///g, (matches, pre, quote, url, post) ->
    pre + quote + callback(url) + quote + post
