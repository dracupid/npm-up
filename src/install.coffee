"use strict"

npm = require './npm'
util = require './util'
{promisify} = require 'nofs'

module.exports = (packages) ->
    unless packages.length then return Promise.resolve()
    util.logInfo "Start to install..."
    console.log packages.join(' ').cyan  + " will be updated".green

    promisify(npm.commands.i) packages
    .then ->
        util.logSucc "Latest packages has been installed!".green
