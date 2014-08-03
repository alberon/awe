# Asset building with Awe

Awe can:

- Compile [Sass](http://sass-lang.com/)/[Compass](http://compass-style.org/) (`.scss`) files to CSS
- Compile [CoffeeScript](http://coffeescript.org/) (`.coffee`) files to JavaScript
- Combine multiple JavaScript/CSS source files into a single file
- Rewrite relative URLs in CSS files that are combined
- Rewrite URLs in symlinked CSS files
- Watch for changes to source files and rebuild automatically

## Coming soon

It cannot yet (but hopefully will in the near future):

- Generate [source maps](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/) for easier debugging
- [Autoprefix](https://github.com/ai/autoprefixer) CSS rules for easier cross-browser compatibility
- Minify JavaScript & CSS files
- Optimise images
- [Automatically reload](http://livereload.com/) your web browser when assets are rebuilt
- Display Growl notifications when there are build errors
- Display an interactive menu for less technical frontend developers
