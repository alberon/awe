fs = require('fs')

module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    shell:

      # Update Ruby gems
      bundle:
        command: 'bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --no-deployment --without=production && bundle update'

      # Build documentation
      docs:
        command: 'sphinx-build -b html docs docs-html'

      pdfdocs:
        command: 'sphinx-build -b latex docs docs-pdf && make -C docs-pdf all-pdf'

    # Delete files
    clean:
      docs:    'docs-html/'
      lib:     'lib-build/'
      man:     'man-build/'
      pdfdocs: 'docs-pdf/'

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
        cwd: 'lib/'
        src: '**/*.iced'
        dest: 'lib-build/'
        ext: '.js'

    # Run unit tests
    mochaTest:
      options:
        bail: true
        reporter: 'spec'
        require: 'lib-build/common'

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
        cwd: 'man/'
        src: '*.[1-8].md'
        dest: 'man-build/'
        ext: ''
        extDot: 'last'

    # Test modified source files
    testMap:
      lib:
        expand: true
        src: 'lib/**/*.iced'

      # options:
      #   additional:
      #     'lib/AssetGroup.iced': 'test/assets.coffee'
      #     'lib/cacheDir.iced':   'test/assets.coffee'
      #     'lib/cmd-build.iced':  'test/assets.coffee'

    # Watch for changes
    watch:
      # Build everything at start & when this file is modified
      buildAll:
        options:
          atBegin: true
        files: 'Gruntfile.coffee'
        tasks: ['clear', 'build']

      # Build docs/
      docs:
        files: 'docs/*'
        # Skip clean:docs because I have issues with Chrome not refreshing properly
        tasks: ['clear', 'shell:docs']

      # Build lib-build/
      lib:
        files: 'lib/**/*.iced'
        tasks: ['clear', 'lib', 'newer:testMap:lib']

      # Build man-build/
      man:
        files: 'man/*.[1-8].md'
        tasks: ['clear', 'man']

      # Run modified test suite
      test:
        files: ['test/**/*.coffee', '!test/**/_*.coffee']
        tasks: ['clear', 'newer:mochaTest:all']

  # Register tasks
  grunt.registerTask 'default',     'Build everything and watch for changes',         ['watch']
  grunt.registerTask 'build',       'Build everything (except PDF docs)',             ['lib', 'man', 'docs']
  grunt.registerTask 'lib',         'Build JavaScript files (lib/ -> lib-build/)',    ['clean:lib', 'coffee:lib']
  grunt.registerTask 'man',         'Build manual pages (man/ -> man-build/)',        ['clean:man', 'markedman:man']
  grunt.registerTask 'docs',        'Build HTML documentation (docs/ -> docs-html/)', ['clean:docs', 'shell:docs']
  grunt.registerTask 'pdfdocs',     'Build PDF documentation (docs/ -> docs-pdf/)',   ['clean:pdfdocs', 'shell:pdfdocs']
  grunt.registerTask 'bundle',      'Update Ruby gems',                               ['shell:bundle']
  grunt.registerTask 'prepublish',  'Build for publishing on npm',                    ['lib', 'man', 'test']

  grunt.registerTask 'test', 'Run unit tests (all tests or specified test suite)', (suite) ->
    if suite
      grunt.config('mochaTest.suite.src', "test/#{suite}.coffee")
      grunt.task.run('mochaTest:suite')
    else
      grunt.task.run('mochaTest:all')

  # Run tests corresponding to modified source files
  grunt.registerMultiTask 'testMap', '(For internal use only)', ->
    additional = this.options().additional
    files = []

    this.files.forEach (file) =>
      file.src.forEach (src) =>
        if matches = src.match /lib\/(.+)\.iced$/
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
  )
