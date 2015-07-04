"use strict"

{path} = fs = require 'nofs'

home = if process.platform is 'win32' then process.env.USERPROFILE else process.env.HOME

cachePath = path.join home, '.npmupcache'

cache = do ->
    try
        fs.readJSONSync cachePath
    catch e
        {}

if cache.lastTime and Date.now() - cache.lastTime > 20 * 60 * 1000 # 20min
    cache.verCache = {}

cache.lastTime = Date.now()

writeCache = (c = cache) ->
    fs.outputJSON cachePath, c, space: 2
    .catch console.log

writeCacheSync = (c = cache) ->
    try
        fs.outputJSONSync cachePath, c, space: 2
    catch e
        console.log e

module.exports = {
    cache
    writeCache
    writeCacheSync
    cachePath
}
