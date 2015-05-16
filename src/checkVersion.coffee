"use strict"

cache = require './cache'
strategy = require './strategy'
latestVer = require './latestVersion'

module.exports = (deps, useCache = true, mirror) ->
    Promise.all deps.map (dep) ->
        name = dep.packageName
        ver = cache.get name
        if ver and useCache
            promise = Promise.resolve ver
        else
            promise = latestVer name, mirror
            .then (ver) ->
                cache.set name, ver
                ver

        promise.then (ver) ->
            if ver
                dep.newVer = ver
                strategy.version dep
            else
                dep.newVer = dep.installedVer
                dep.needUpdate = false
            dep
    .then (deps) ->
        cache.record()
        deps
