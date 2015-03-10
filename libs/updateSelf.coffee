require 'colors'
{get} = require 'https'
{Promise} = require 'nofs'
semver = require 'semver'

util = require './util'
getVer = require './latestVersion'
{cache, writeCache} = require './data'

interval = 12 * 3600 * 1000 # 12 hours

module.exports = (mirror) ->
    promise = Promise.resolve()

    if not cache.lastCheck or Date.now() - cache.lastCheck > interval
        promise = promise.then ->
            getVer 'npm-up', mirror
        .then (ver) ->
            cache.latest = ver
            cache.lastCheck = Date.now()
            writeCache cache

    promise = promise.then ->
        installed = util.curVer
        latest = cache.latest
        if semver.lt installed, latest
            "\n>> A new version of npm-up is available:".yellow +
                " #{('' + installed).green} --> #{('' + latest).red}"
        else ""
    .catch -> return

    promise.log = ->
        promise.then (msg) ->
            msg and console.log msg

    promise
