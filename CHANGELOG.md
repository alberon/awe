# Awe Changelog

This project uses [Semantic Versioning](http://semver.org/).

## 0.0.4 - 4 Aug 2014

- Add more info to `package.json` to display on the [npm website](https://www.npmjs.org/package/awe)

## 0.0.3 - 4 Aug 2014

- Bug fix - `rimraf` was in `devDependencies` not `dependencies`

## 0.0.2 - 4 Aug 2014

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

## 0.0.1 - 17 May 2014

- Proof of concept / placeholder to register the name on [npm](https://www.npmjs.org/package/awe).
