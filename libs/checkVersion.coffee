cache = require './cache'
Version = require './Version'
strategy = require './strategy'
npm = require 'npm'

module.exports = (deps) ->
    npmView = Promise.promisify(npm.commands.v)

    Promise.all deps.map (dep)->
        name = dep.packageName
        ver = cache.get name
        if ver
            promise = Promise.resolve ver
        else
            promise = npmView([name, 'dist-tags.latest'], true)
            .then (data)->
                ver = _(data).keys().first()
                cache.set name, ver
                ver

        promise.then (ver)->
            dep.newVer = new Version ver
            strategy.version dep
    .then (deps)->
        cache.record()
        deps
