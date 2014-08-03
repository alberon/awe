# Grunt tasks for Awe


## Installing Grunt

If you don't already have the Grunt CLI installed, you can install it with npm:

```bash
$ sudo npm install -g grunt-cli
```

## Available tasks

The following tasks are used when developing Awe:

```bash
# Rebuild `lib/` from `lib-src/` (CoffeeScript to JavaScript)
$ grunt lib

# Rebuild `man/` from `man-src/` (Markdown to Man pages)
$ grunt man

# Rebuild everything
$ grunt build

# Rebuild everything and watch for further changes
$ grunt watch
$ grunt         # This is the default task

# Run all unit tests
$ grunt test

# Run unit tests in `test/<suite>.coffee` only
$ grunt test <suite>

# Update the Ruby gems to the latest version
$ grunt bundle
```

## Watch and unit tests

Some unit tests are run automatically when you modify the related source files. However, some unit tests are slow, so not all tests are run - you should run them manually instead (`grunt test`). To change which tests are run, simply modify [`Gruntfile.coffee`](../Gruntfile.coffee).
