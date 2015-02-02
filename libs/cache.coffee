{npmuprc, writeRC} = require './npmuprc'

npmuprc.verCache ?= {}

expire = 10 * 60 * 1000 # 10 min

get = (name)->
    info = npmuprc.verCache[name]
    now = +new Date()
    if info
        interval = info.expire or expire
        if now - info.timestamp < interval
            info.version
        else
            delete npmuprc.verCache[name]
            ''
    else
        ''

set = (name, ver)->
    npmuprc.verCache[name] =
        version: ver
        timestamp: +new Date()

module.exports = {
    get
    set
    record: writeRC
}
