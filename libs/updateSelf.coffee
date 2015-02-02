fs = require 'nofs'
Promise = require 'bluebird'
path = require 'path'
util = require './util'
_ = require 'lodash'
npm = require 'npm'
Version = require './Version'
require 'colors'

{npmuprc, writeRC} = require './npmuprc'

interval = 12 * 3600 * 1000 # 12 hours

checkUpdate = ->
    rc = npmuprc
    promise = Promise.resolve()

    if not rc.lastCheck or + new Date() - rc.lastCheck > interval
        promise = Promise.promisify(npm.load)
            loglevel: 'error'
        .then ->
            Promise.promisify(npm.commands.v)(['npm-up', 'dist-tags.latest'], true)
        .then (data) ->
            rc.latest = _(data).keys().first()
            rc.lastCheck = + new Date()
        .then ->
            writeRC rc

    promise.then ->
        installed = new Version util.curVer
        latest = new Version rc.latest
        if installed.compareTo(latest) < 0
            console.log ">>  A new version of npm-up is available !".yellow, " #{('' + installed).green} --> #{('' + latest).red}"

module.exports = checkUpdate
