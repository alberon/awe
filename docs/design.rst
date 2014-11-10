##################
 Design decisions
##################

Awe is designed for use at `Alberon <http://www.alberon.co.uk>`_, a web/software development agency managing many different websites.

It relies on convention rather than configuration, to make it easy to use and ensure consistency between sites.

It is installed system-wide, not per-project, to avoid the maintenance overhead of installing and upgrading it for each site separately.

Unlike `Grunt <http://gruntjs.com/>`_ and `Gulp <http://gulpjs.com/>`_, Awe is not designed to be a general purpose task runner or build tool - so it won't suit everyone, but it should be much easier to configure.

I didn't use Grunt because I found it hard to configure once the build steps start to get complicated.

I didn't use Gulp because I found the error handling to be tricky to get right, and although it was easier than Grunt I still found it required too much configuration. I also didn't like having to manually install and update several packages on each site.

I didn't use Brocolli because it didn't seem mature enough.

Backwards-compatibility is important, so all important functions have unit tests to ensure nothing breaks.

Forwards-compatibility is also important, so the default settings are very conservative - all features must be explicitly enabled.

Explicit is better than implicit, to avoid confusion and reduce the need to refer to the documentation.
