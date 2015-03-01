Promise = require 'bluebird'
util = require './util'
npm = require './npm'
semver = require 'semver'
require 'colors'

{npmuprc, writeRC} = require './npmuprc'

interval = 12 * 3600 * 1000 # 12 hours

checkUpdate = ->
    rc = npmuprc
    promise = Promise.resolve()

    if not rc.lastCheck or Date.now() - rc.lastCheck > interval
        promise = Promise.promisify(npm.load)
            loglevel: 'error'
        .then ->
            Promise.promisify(npm.commands.v)(['npm-up', 'dist-tags.latest'], true)
        .then (data) ->
            rc.latest = Object.keys(data)[0]
            rc.lastCheck = Date.now()
        .then ->
            writeRC rc

    promise.then ->
        installed = util.curVer
        latest = rc.latest
        if semver.lt installed, latest
            console.log ">>  A new version of npm-up is available !".yellow, " #{('' + installed).green} --> #{('' + latest).red}"

module.exports = checkUpdate
