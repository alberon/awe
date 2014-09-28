fs = require('fs')

module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    # Update Ruby gems
    shell:
      bundle:
        command: 'bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --no-deployment --without=production'

    # Delete files
    clean:
      lib: 'lib/'
      man: 'man/'

    # Compile CoffeeScript files
    coffee:
      options:
        bare: true
        header: true
        runtime: 'node'
        sourceMap: true

      lib:
        expand: true
        nonull: true
        cwd: 'lib-src/'
        src: '**/*.iced'
        dest: 'lib/'
        ext: '.js'

    # Run unit tests
    mochaTest:
      options:
        bail: true
        reporter: 'spec'
        require: 'lib/source-map-support'

      all:
        src: ['test/**/*.coffee', '!test/**/_*.coffee']

      # quick:
      #   options:
      #     reporter: 'dot'
      #   src: ['test/**/*.coffee', '!test/**/_*.coffee']

    # Generate man pages
    markedman:
      options:
        manual: 'Awe Manual'
        version: 'Awe <%= pkg.version %>'
      man:
        expand: true
        nonull: true
        cwd: 'man-src/'
        src: '*.[1-8].md'
        dest: 'man/'
        ext: ''
        extDot: 'last'

    # Test modified source files
    testMap:
      lib:
        expand: true
        src: 'lib-src/**/*.iced'

      # options:
      #   additional:
      #     'lib-src/AssetGroup.iced': 'test/assets.coffee'
      #     'lib-src/cacheDir.iced':   'test/assets.coffee'
      #     'lib-src/cmd-build.iced':  'test/assets.coffee'

    # Watch for changes
    watch:
      # Build everything
      buildAll:
        options:
          atBegin: true
        files: 'Gruntfile.coffee'
        tasks: ['clear', 'build']

      # Build lib/
      lib:
        files: 'lib-src/**/*.iced'
        tasks: ['clear', 'lib', 'newer:testMap:lib']

      # Build man/
      man:
        files: 'man-src/*.[1-8].md'
        tasks: ['clear', 'man']

      # Run modified test suite
      test:
        files: ['test/**/*.coffee', '!test/**/_*.coffee']
        tasks: ['clear', 'newer:mochaTest:all']

  # Register tasks
  grunt.registerTask('default', 'Rebuild everything and watch for changes', ['watch'])
  grunt.registerTask('build', 'Rebuild everything', ['lib', 'man'])
  grunt.registerTask('bundle', 'Update Ruby gems', ['shell:bundle'])
  grunt.registerTask('lib', 'Rebuild lib/ from lib-src/', ['clean:lib', 'coffee:lib'])
  grunt.registerTask('man', 'Rebuild man/ from man-src/', ['clean:man', 'markedman:man'])

  grunt.registerTask 'test', 'Run unit tests (all tests or specified test suite)', (suite) ->
    if suite
      grunt.config('mochaTest.suite.src', "test/#{suite}.coffee")
      grunt.task.run('mochaTest:suite')
    else
      grunt.task.run('mochaTest:all')

  grunt.registerMultiTask 'testMap', ->
    additional = this.options().additional
    files = []

    this.files.forEach (file) =>
      file.src.forEach (src) =>
        if matches = src.match /lib-src\/(.+)\.(coffee|iced)$/
          files.push("test/#{matches[1]}.coffee")
        if additional && src of additional
          if additional[src] instanceof Array
            files = files.concat(additional[src])
          else
            files.push(additional[src])

    grunt.config('mochaTest.modified.src', files)
    grunt.task.run('mochaTest:modified')

  # Lazy-load plugins & custom tasks
  require('jit-grunt')(grunt,
    coffee: 'grunt-iced-coffee'
  )(
    customTasksDir: 'tasks/'
  )
