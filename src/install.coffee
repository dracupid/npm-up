"use strict"

npm = require './npm'
util = require './util'

module.exports = (packages, cwd = null) ->
    unless packages.length then return Promise.resolve()
    util.logInfo "Start to install..."
    console.log packages.join(' ').cyan  + " will be updated".green

    util.promisify(npm.commands.i) cwd, packages
    .then ->
        util.logSucc "Latest packages has been installed!".green
