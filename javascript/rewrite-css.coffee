#!/usr/bin/env coffee

fs          = require('fs')
path        = require('path')
rewriteCss  = require('./lib/rewriteCss')
S           = require('string')
UrlRewriter = require('./lib/UrlRewriter')

rootPath     = process.argv[2]
srcDir       = process.argv[3]
srcFile      = process.argv[4]
destDir      = process.argv[5]
destFile     = process.argv[6]
bowerSrc     = process.argv[7]
bowerDest    = process.argv[8]
autoprefixer = process.argv[9] == '1'

stdin  = process.stdin  # 0
stdout = process.stdout # 1
stderr = process.stderr # 2
mapin  = fs.createReadStream(null, fd: 3) # 3
mapout = fs.createWriteStream(null, fd: 4) # 4


# For easier debugging
mapout.on 'error', (e) ->
    if e.code == 'EBADF'
        stderr.write("File descriptor #4 is not writeable - cannot output source map\n")
    else
        throw e


# Input
code = ''
map  = ''

stdin.on 'data', (buffer) ->
    code += buffer.toString() if buffer

mapin.on 'data', (buffer) ->
    map += buffer.toString() if buffer


finishCount = 0
finishedInput = ->
    finishCount++
    if finishCount == 2
        run()

stdin.on 'end', finishedInput
mapin.on 'end', finishedInput


# URL rewriter
urlRewriter = new UrlRewriter
    root:      rootPath
    srcDir:    srcDir
    srcFile:   srcFile
    destDir:   destDir
    destFile:  destFile
    bowerSrc:  bowerSrc
    bowerDest: bowerDest

rewriteUrl = (url) =>
    if S(url).startsWith('/AWEDESTROOTPATH/')
        return path.join(path.relative(path.dirname(srcFile), srcDir), url[17..])

    try
        return urlRewriter.rewrite(url)
    catch e
        stderr.write(e.message)
        return url


# Main function
run = ->
    map = JSON.parse(map)

    # Workaround for Error: Unsupported previous source map format
    if map && map.sources.length == 0
        map = null

    try
        result = rewriteCss(
            code,
            path.relative(srcDir, srcFile),
            destFile,
            sourcemap: true,
            prevSourcemap: map,
            autoprefixer: autoprefixer,
            rewriteUrls: rewriteUrl
        )
    catch e
        throw e unless e.source # Looks like a CSS error
        stderr.write("#{e.reason} on line #{e.line} column #{e.column}")
        return

    stdout.write(result.css)
    mapout.write(JSON.stringify(result.map.toJSON()))
