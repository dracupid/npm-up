"use strict"

require 'colors'
{Promise} = require 'nofs'
semver = require 'semver'

util = require './util'
checkVer = require './checkVersion'

interval = 12 * 3600 * 1000 # 12 hours

module.exports = (mirror) ->
    promise = checkVer ['npm-up'], true, mirror, interval
    .then ([latest]) ->
        installed = util.curVer
        console.log installed, latest
        if semver.lt installed, latest
            "\n>> A new version of npm-up is available:".yellow +
                " #{('' + installed).green} --> #{('' + latest).red}"
        else ""
    .catch -> return

    promise.log = ->
        promise.then (msg) -> msg and console.log msg

    promise
