#!/usr/bin/env coffee

# This simply compiles coffeescript from stdin and outputs it to stdout (like
# `coffee`), but also outputs the sourcemap on fd 3 so there's no need to
# create temporary files

fs = require('fs')
coffee = require('coffee-script')

srcfile = process.argv[2]
destfile = process.argv[3]
code = ''

input  = process.stdin # 0
output = process.stdout # 1
error  = process.stderr # 2
map    = fs.createWriteStream(null, fd: 3) # 3

# For easier debugging
map.on 'error', (e) ->
    if e.code == 'EBADF'
        error.write("File descriptor #3 is not writeable - cannot output source map\n")
    else
        throw e

input.on 'data', (buffer) ->
    code += buffer.toString() if buffer

input.on 'end', ->
    # Compile CoffeeScript
    try
        result = coffee.compile code,
            sourceMap:     true
            sourceFiles:   [srcfile]
            generatedFile: [destfile]
    catch e
        error.write(e.toString().replace('[stdin]:', ''))
        return

    # Output JavaScript
    output.write(result.js)

    # Output source map
    map.write(result.v3SourceMap)
