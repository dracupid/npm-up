"use strict"

chalk = require 'chalk'
semver = require 'semver'

util = require './util'
checkVer = require './checkVersion'

interval = 12 * 3600 * 1000 # 12 hours

module.exports = (mirror) ->
    promise = checkVer ['npm-up'], true, mirror, interval
    .then ([latest]) ->
        installed = util.curVer + ''
        if semver.lt installed, latest
            chalk.yellow.bold "\n>> New npm-up available:",
                chalk.green(latest), chalk.grey "(current: #{installed})"
        else ""
    .catch -> return

    promise.log = ->
        promise.then (msg) -> msg and console.log msg

    promise
