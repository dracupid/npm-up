"use strict"

{cache, writeCache} = require './data'

cache.verCache ?= {}

get = (name, expire = 1000) ->
    info = cache.verCache[name]
    if info
        interval = info.expire or expire
        if Date.now() - info.t < interval
            if typeof info.version == 'string' # cleanup cache from previous version
                null
            else
                info.version
        else
            delete cache.verCache[name]
            null
    else
        null

set = (name, verObj) ->
    cache.verCache[name] =
        version: verObj
        t: Date.now()

module.exports = {
    get
    set
    record: writeCache
}
