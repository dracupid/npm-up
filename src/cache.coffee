"use strict"

{cache, writeCache} = require './data'

cache.verCache ?= {}

get = (name, expire = 1000) ->
    info = cache.verCache[name]
    if info
        interval = info.expire or expire
        if Date.now() - info.timestamp < interval
            info.version
        else
            delete cache.verCache[name]
            ''
    else
        ''

set = (name, ver) ->
    cache.verCache[name] =
        version: ver
        timestamp: Date.now()

module.exports = {
    get
    set
    record: writeCache
}
