chalk = require('chalk')
fs    = require('fs')

module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    # Shell commands
    shell:

      # Update Ruby gems
      'update-gems':
        command: 'bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --no-deployment --without=production && bundle update'

      # Build documentation
      docs:
        command: 'sphinx-build -b html docs docs-html'

      pdfdocs:
        command: 'sphinx-build -b latex docs docs-pdf && make -C docs-pdf all-pdf'

      # Deploy
      deploy:
        command: 'echo "Updating Awe on Jericho..."; ssh -p 52222 root@jericho.alberon.co.uk "npm --color=always update -g awe"'

    # Delete files
    clean:
      docs:      'docs-html/'
      docsCache: 'docs-html/.buildinfo'
      lib:       'lib-build/'
      man:       'man-build/'
      pdfdocs:   'docs-pdf/'

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
        files: 'docs/*.*'
        # Skip clean:docs because I have issues with Chrome not refreshing
        # properly if I happen to refresh too fast and get a Not Found page -
        # for some reason after that I can't see the new version
        tasks: ['clear', 'shell:docs']

      docsAssets:
        files: 'docs/_static/*.*'
        tasks: ['clear', 'clean:docsCache', 'shell:docs']

      # Build lib-build/
      lib:
        files: 'lib/**/*.iced'
        tasks: ['clear', 'build-lib', 'newer:testMap:lib']

      # Build man-build/
      man:
        files: 'man/*.[1-8].md'
        tasks: ['clear', 'build-man']

      # Run modified test suite
      test:
        files: ['test/**/*.coffee', '!test/**/_*.coffee']
        tasks: ['clear', 'newer:mochaTest:all']

  # Register tasks
  grunt.registerTask 'build', ['build-lib', 'build-man', 'build-docs-html']
  grunt.registerTask 'build-docs-html', ['clean:docs', 'shell:docs']
  grunt.registerTask 'build-docs-pdf', ['clean:pdfdocs', 'shell:pdfdocs']
  grunt.registerTask 'build-lib', ['clean:lib', 'coffee:lib']
  grunt.registerTask 'build-man', ['clean:man', 'markedman:man']
  grunt.registerTask 'deploy', ['shell:deploy']
  grunt.registerTask 'update-gems', ['shell:update-gems']

  # Undocumented task to run before npm publishes the package
  grunt.registerTask 'prepublish', ['build-lib', 'build-man', 'test']

  # The test command is a bit more complex as it takes an optional filename
  grunt.registerTask 'test', (suite) ->
    if suite
      grunt.config('mochaTest.suite.src', "test/#{suite}.coffee")
      grunt.task.run('mochaTest:suite')
    else
      grunt.task.run('mochaTest:all')

  # Default to displaying help
  grunt.registerTask 'default', ['help']

  grunt.registerTask 'help', ->
    grunt.log.writeln """

      #{chalk.bold.underline('AVAILABLE COMMANDS')}

      #{chalk.bold('grunt build')}             Build (almost) everything (lib/, man/ and docs/ - excludes PDF docs)
      #{chalk.bold('grunt build-docs-html')}   Build HTML documentation (docs/ → docs-html/)
      #{chalk.bold('grunt build-docs-pdf')}    Build PDF documentation (docs/ → docs-pdf/)
      #{chalk.bold('grunt build-lib')}         Build JavaScript files (lib/ → lib-build/)
      #{chalk.bold('grunt build-man')}         Build manual pages (man/ → man-build/)
      #{chalk.bold('grunt deploy')}            Upgrade Awe on Alberon servers (currently only Jericho)
      #{chalk.bold('grunt test')}              Run all unit/integration tests
      #{chalk.bold('grunt test:<suite>')}      Run the specified test suite (e.g. 'grunt test:config')
      #{chalk.bold('grunt update-gems')}       Update Ruby gems to the latest allowed version (according to Gemfile)
      #{chalk.bold('grunt watch')}             Run 'build' then watch for further changes and build / run tests automatically
    """

  # Run tests corresponding to modified source files
  grunt.registerMultiTask 'testMap', '(For internal use only)', ->
    additional = this.options().additional
    files = []

    # Loop through all the modified files
    this.files.forEach (file) =>
      file.src.forEach (src) =>
        # Does it have a matching unit test suite?
        if matches = src.match /lib\/(.+)\.iced$/
          files.push("test/#{matches[1]}.coffee")

        # Any additional tests that should be run for this file?
        if additional && src of additional
          if additional[src] instanceof Array
            files = files.concat(additional[src])
          else
            files.push(additional[src])

    # Run the test suite for those files only
    grunt.config('mochaTest.modified.src', files)
    grunt.task.run('mochaTest:modified')

  # Lazy-load plugins & custom tasks
  require('jit-grunt')(grunt,
    coffee:         'grunt-iced-coffee'
  )
