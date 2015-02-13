{npmuprc, writeRC} = require './npmuprc'

npmuprc.verCache ?= {}

expire = 20 * 60 * 1000 # 20 min

get = (name)->
    info = npmuprc.verCache[name]
    now = Date.now()
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
        timestamp: Date.now()

module.exports = {
    get
    set
    record: writeRC
}
