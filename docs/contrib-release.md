# Releasing new versions of Awe

## Preparation

- Check the documentation is up-to-date
- Update [`CHANGELOG.md`](../CHANGELOG.md) with the list of changes

## Release

- Run `npm version X.Y.Z` to update `package.json`
- Run `git push && git push --tags` to upload the code and tag to GitHub
- Run `npm publish` to upload to npm

## Finalising

- Run `sudo npm update -g awe` to upgrade Awe
