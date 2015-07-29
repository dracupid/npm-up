"use strict"

npm = require './npm'
util = require './util'
chalk = require 'chalk'

module.exports = (packages, cwd = null) ->
    unless packages.length then return Promise.resolve()
    util.logInfo "Start to install..."
    console.log chalk.cyan packages.join(', ')  + chalk.green " will be updated"

    util.promisify(npm.commands.i) cwd, packages
    .then ->
        util.logSucc chalk.green "Latest packages has been installed!"
