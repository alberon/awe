# Releasing new versions of Awe

- Update the version number in `package.json`
- Update [`CHANGELOG.md`](../CHANGELOG.md)
- Commit the changes
- Upload to npm `npm publish`
- Tag the release `git tag 1.0.0`
- Upload the code and tag to GitHub `git push && git push --tags`

*TODO: Automate most of this with Grunt!*
