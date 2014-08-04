# Releasing new versions of Awe

- Update [`CHANGELOG.md`](../CHANGELOG.md) with the list of changes
- Run `npm version X.Y.Z` to update `package.json`
- Run `git push && git push --tags` to upload the code and tag to GitHub
- Run `npm publish` to upload to npm
