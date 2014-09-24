fs = require('fs')

module.exports = (chai, utils) ->

  # expect(path).to.be.a.symlink()
  # expect(path).not.to.be.a.symlink()
  chai.Assertion.addMethod 'symlink', ->

    try
      isSymlink = fs.lstatSync(this._obj).isSymbolicLink()
    catch err
      # If it doesn't exist, it's clearly not a symlink
      if err.code == 'ENOENT'
        isSymlink = false
      else
        throw err

    this.assert(
      isSymlink,
      'expected #{this} to be a symlink',
      'expected #{this} not to be a symlink'
    )
