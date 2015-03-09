{Promise} = require 'nofs'
util = require './util'
npm = require './npm'
semver = require 'semver'
require 'colors'

{cache, writeCache} = require './data'

interval = 12 * 3600 * 1000 # 12 hours

checkUpdate = ->
    promise = Promise.resolve()

    if not cache.lastCheck or Date.now() - cache.lastCheck > interval
        promise = Promise.promisify(npm.load)
            loglevel: 'error'
        .then ->
            Promise.promisify(npm.commands.v)(['npm-up', 'dist-tags.latest'], true)
        .then (data) ->
            cache.latest = Object.keys(data)[0]
            cache.lastCheck = Date.now()
        .then ->
            writeCache cache

    promise.then ->
        installed = util.curVer
        latest = cache.latest
        if semver.lt installed, latest
            console.log ">>  A new version of npm-up is available !".yellow, " #{('' + installed).green} --> #{('' + latest).red}"

module.exports = checkUpdate
