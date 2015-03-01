#!/usr/bin/env coffee

# This simply compiles coffeescript from stdin and outputs it to stdout (like
# `coffee`), but also outputs the sourcemap on fd 3 so there's no need to
# create temporary files

fs     = require('fs')
coffee = require('coffee-script')

srcfile  = process.argv[2]
destfile = process.argv[3]

stdin  = process.stdin  # 0
stdout = process.stdout # 1
stderr = process.stderr # 2
mapout = fs.createWriteStream(null, fd: 3) # 3

# For easier debugging
mapout.on 'error', (e) ->
    if e.code == 'EBADF'
        stderr.write("File descriptor #3 is not writeable - cannot output source map\n")
    else
        throw e

code = ''

stdin.on 'data', (buffer) ->
    code += buffer.toString() if buffer

stdin.on 'end', ->
    # Compile CoffeeScript
    try
        result = coffee.compile code,
            sourceMap:     true
            sourceFiles:   [srcfile]
            generatedFile: [destfile]
    catch e
        stderr.write(e.toString().replace('[stdin]:', ''))
        return

    # Output JavaScript
    stdout.write(result.js)

    # Output source map
    mapout.write(result.v3SourceMap)
