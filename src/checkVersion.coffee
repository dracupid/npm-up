"use strict"

cache = require './cache'
strategy = require './strategy'
latestVer = require './latestVersion'
EXPIRE = 20 * 60 * 1000 # 20 min
{Promise} = require 'nofs'

resolveVerTag = (verObj, tag = 'latest') ->
    return '' if not verObj
    verObj[tag] or ''

module.exports = (deps, useCache = true, mirror, expire = EXPIRE, tag) ->
    Promise.all deps.map (dep) ->
        name = if typeof dep is 'object' then dep.packageName else dep
        verObj = cache.get name, expire
        tag = if (typeof dep is 'object' and dep.tryTag) then dep.declareVer else 'latest'

        promise =
            if verObj and useCache
                Promise.resolve resolveVerTag verObj, tag
            else
                latestVer name, mirror
                .then (verObj) ->
                    cache.set name, verObj
                    resolveVerTag verObj, tag

        if typeof dep is 'object'
            promise.then (ver) ->
                if ver
                    dep.newVer = ver
                    dep.installName = if dep.tryTag then tag else ver
                    if dep.tryTag then dep.declareVer = ver
                    strategy.version dep
                else
                    dep.installName = dep.newVer = dep.installedVer
                    dep.needUpdate = false
                dep
        else
            promise
    .then (deps) ->
        cache.record()
        deps
