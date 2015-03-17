chalk  = require('chalk')
fs     = require('fs')
semver = require('semver')

module.exports = (grunt) ->

  pkg = grunt.file.readJSON('package.json')

  grunt.initConfig

    pkg: pkg

    # Change this for testing the publish task
    # (Also change "name" in package.json to "awe-test-package")
    repo: 'git@github.com:alberon/awe.git'

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

    # Interactive prompts
    prompt:

      # Confirm documentation has been updated
      'publish-confirm':
        options:
          questions: [
            {
              config:  'confirmed'
              type:    'confirm'
              message: 'Did you remember to update the documentation?'
            }
          ]
          then: (answers) ->
            if ! answers.confirmed
              grunt.log.writeln()
              grunt.fail.fatal('Hmm... Better go do that then.', 0)

      # Ask which version number to use
      'publish-version':
        options:
          questions: [
            {
              config:  'version'
              type:    'list'
              message: 'Bump version from <%= pkg.version %> to:',
              choices: [
                {
                  value: (v = semver.inc(pkg.version, 'patch')),
                  name:  chalk.yellow(v) + '   Backwards-compatible bug fixes'
                },
                {
                  value: (v = semver.inc(pkg.version, 'minor')),
                  name:  chalk.yellow(v) + '   Add functionality in a backwards-compatible manner'
                },
                {
                  value: (v = semver.inc(pkg.version, 'major')),
                  name:  chalk.yellow(v) + '   Incompatible API changes'
                },
                {
                  value: 'custom',
                  name:  chalk.yellow('Custom') + '  Specify version...'
                }
              ]
            }
            {
              config:  'version',
              type:    'input',
              message: 'What specific version would you like?',
              when: (answers) -> answers.version == 'custom'
              validate: (value) ->
                if semver.valid(value)
                  true
                else
                  'Must be a valid semver, such as 1.2.3-rc1. See http://semver.org/ for more details.'
            }
          ]

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

      # Publish (from local to GitHub and npm)
      'publish-check':
        command: 'scripts/publish-check.sh "<%= repo %>"'

      'publish-show-log':
        command: 'git log --pretty=format:"%C(red)%h %C(yellow)%s %C(green)(%cr) %C(bold blue)<%an>%C(reset)" refs/tags/v<%= pkg.version%>..'

      'publish-version':
        command: 'npm version <%= version %>'

      'publish-push':
        command: 'git push "<%= repo %>" refs/heads/master refs/tags/v<%= version %>'

      'publish-npm':
        command: 'npm publish'

      # Deploy (from npm to Jericho)
      deploy:
        command: 'echo "Updating Awe on Jericho..."; ssh -p 52222 root@jericho.alberon.co.uk "npm --color=always update -g awe"'

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
  grunt.registerTask 'build',           ['build-lib', 'build-man', 'build-docs-html']
  grunt.registerTask 'build-docs-html', ['clean:docs', 'shell:docs']
  grunt.registerTask 'build-docs-pdf',  ['clean:pdfdocs', 'shell:pdfdocs']
  grunt.registerTask 'build-lib',       ['clean:lib', 'coffee:lib']
  grunt.registerTask 'build-man',       ['clean:man', 'markedman:man']
  grunt.registerTask 'deploy',          ['shell:deploy']
  grunt.registerTask 'update-gems',     ['shell:update-gems']

  grunt.registerTask 'publish', [
    'shell:publish-check'    # Check everything is checked in and merged
    'prompt:publish-confirm' # Check the documentation is up-to-date
    'shell:publish-show-log' # Display list of changes
    'prompt:publish-version' # Ask the user for the version number to use
    'build-lib'              # Build the files
    'build-man'              # Build the manual pages
    'test'                   # Run the unit tests
    'shell:publish-version'  # Update package.json, commit and tag the version
    'shell:publish-push'     # Upload the tag to GitHub
    'shell:publish-npm'      # Upload the release to npm
  ]

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
      #{chalk.bold('grunt publish')}           Release a new version of Awe (upload to GitHub & npm)
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
    coffee: 'grunt-iced-coffee'
  )
