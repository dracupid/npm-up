{get} = require 'https'
require 'colors'
{Promise} = require 'nofs'
util = require './util'
semver = require 'semver'

{cache, writeCache} = require './data'

interval = 12 * 3600 * 1000 # 12 hours

getInfo = ->
    new Promise (resolve, reject) ->
        get 'https://registry.npmjs.org/npm-up/latest', (res) ->
            res.setEncoding 'utf8'
            data = ''
            res.on 'data', (d) -> data += d
            res.on 'end', -> resolve data
        .on 'error', -> reject()

module.exports = ->
    promise = Promise.resolve()

    if not cache.lastCheck or Date.now() - cache.lastCheck > interval
        promise = promise.then ->
            getInfo()
        .then (data) ->
            { version: cache.latest } = JSON.parse data
            cache.lastCheck = Date.now()
            writeCache cache

    promise.then ->
        installed = util.curVer
        latest = cache.latest
        if semver.lt installed, latest
            console.log ">>  A new version of npm-up is available !".yellow,
                " #{('' + installed).green} --> #{('' + latest).red}"
    .catch -> return
