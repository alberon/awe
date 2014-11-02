# Changelog for Awe

This project uses [Semantic Versioning](http://semver.org/).

### 0.1.0 - Unreleased

- `awe build`
  - Add support for Autoprefixer
  - ...

### 0.0.5 - 7 Sep 2014

- `awe build`
  - Don't attempt to rewrite URLs inside CSS comments
- `awe watch`
  - Bug fix - Prevent crash when multiple files are changed at once (by debouncing and queuing)
  - Use `fs.watch()` instead of `fs.watchFile()` - triggers much faster

### 0.0.4 - 4 Aug 2014

- Add more info to `package.json` to display on the [npm website](https://www.npmjs.org/package/awe)

### 0.0.3 - 4 Aug 2014

- `awe build`
  - Bug fix - `rimraf` was in `devDependencies` not `dependencies`

### 0.0.2 - 4 Aug 2014

- `awe build` (new)
  - Compile `.scss` and `.coffee` files
  - Combine `.js` and `.css` directories to a single output file
  - Copy all other files unchanged
- `awe help` (new)
  - Display basic help
- `awe init` (new)
  - Create awe.yaml in the current directory
- `awe version` (new)
  - Display the Awe version number
- `awe watch` (new)
  - Watch for changes and rebuild automatically

### 0.0.1 - 17 May 2014

- Proof of concept / placeholder to register the name on [npm](https://www.npmjs.org/package/awe)
