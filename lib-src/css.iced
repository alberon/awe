css = require('css')


exports.rewriteUrls = (content, callback) ->

  regex = ///
    (url\()  # url(
    (['"]?)  # open quote, optional
    (.*?)    # URL - ungreedy
    \2       # close quote
    (\))     # )
  ///g

  visitNode = (node) ->
    if node.type == 'stylesheet'
      node.stylesheet.rules.forEach(visitNode)
    else if node.type == 'rule' || node.type == 'font-face'
      node.declarations.forEach(visitNode)
    else if node.type == 'declaration'
      rewriteNode(node)

  rewriteNode = (node) ->
    node.value = node.value.replace regex, (matches, pre, quote, url, post) ->
      pre + quote + callback(url) + quote + post

  ast = css.parse(content)
  visitNode(ast)
  css.stringify(ast)
