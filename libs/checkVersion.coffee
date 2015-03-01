cache = require './cache'
strategy = require './strategy'
npm = require './npm'
Promise = require 'bluebird'

module.exports = (deps, useCache) ->
    npmView = Promise.promisify(npm.commands.v)
    Promise.all deps.map (dep) ->
        name = dep.packageName
        ver = cache.get name
        if ver and useCache
            promise = Promise.resolve ver
        else
            promise = npmView([name, 'dist-tags.latest'], true)
            .then (data) ->
                ver = Object.keys(data)[0]
                cache.set name, ver
                ver

        promise.then (ver) ->
            dep.newVer = ver
            strategy.version dep
    .then (deps) ->
        cache.record()
        deps
