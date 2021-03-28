"use strict"

npm = require './npm'
util = require './util'
chalk = require 'chalk'
{Promise} = require 'nofs'
semver = require 'semver'

module.exports = (packages, cwd = null) ->
    unless packages.length then return Promise.resolve()
    util.logInfo "Start to install..."
    console.log chalk.cyan packages.join(', ')  + chalk.green " will be updated"
    promise = null
    cmd = npm.commands.i
    if (semver.gte(npm.version, '7.0.0'))
        if cwd
            npm.config.set('prefix', cwd)
        promise = util.promisify(cmd.exec.bind(cmd)) packages

    else
        promise = (
            if cwd
                util.promisify(cmd) cwd, packages
            else
                util.promisify(cmd) packages
        )
    promise.then ->
        util.logSucc chalk.green "Latest packages have been installed!"
