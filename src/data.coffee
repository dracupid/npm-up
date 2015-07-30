"use strict"

fs = require 'nofs'
path = require 'path'
os = require 'os'

homedir = do ->
    if typeof os.homedir is 'function'
        os.homedir()
    else
        process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']

cachePath = path.join homedir, '.npmupcache'

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
    .catch console.error

writeCacheSync = (c = cache) ->
    try
        fs.outputJSONSync cachePath, c, space: 2
    catch e
        console.error e

module.exports = {
    cache
    writeCache
    writeCacheSync
    cachePath
}
