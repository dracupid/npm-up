"use strict"

npm = require './npm'
util = require './util'
chalk = require 'chalk'
{Promise} = require 'nofs'

module.exports = (packages, cwd = null) ->
    unless packages.length then return Promise.resolve()
    util.logInfo "Start to install..."
    console.log chalk.cyan packages.join(', ')  + chalk.green " will be updated"
    (
        if cwd
            util.promisify(npm.commands.i) cwd, packages
        else
            util.promisify(npm.commands.i) packages
    ).then ->
        util.logSucc chalk.green "Latest packages have been installed!"
