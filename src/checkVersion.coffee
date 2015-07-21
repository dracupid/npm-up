"use strict"

cache = require './cache'
strategy = require './strategy'
latestVer = require './latestVersion'
EXPIRE = 20 * 60 * 1000 # 20 min

module.exports = (deps, useCache = true, mirror, expire = EXPIRE) ->
    Promise.all deps.map (dep) ->
        name = if typeof dep is 'object' then dep.packageName else dep
        ver = cache.get name, expire

        promise =
            if ver and useCache
                Promise.resolve ver
            else
                latestVer name, mirror
                .then (ver) ->
                    cache.set name, ver
                    ver

        if typeof dep is 'object'
            promise.then (ver) ->
                if ver
                    dep.newVer = ver
                    strategy.version dep
                else
                    dep.newVer = dep.installedVer
                    dep.needUpdate = false
                dep
        else
            promise
    .then (deps) ->
        cache.record()
        deps
