{path} = fs = require 'nofs'

home = if process.platform is 'win32' then process.env.USERPROFILE else process.env.HOME
rcPath = path.join home, '.npmuprc.json'

do ->
    fs.outputJSONSync rcPath, {}, space: 2 # clean old cache

tmpDir = require('os').tmpDir()
cachePath = path.join tmpDir, 'npmUpCache'

cache = do ->
    try
        require cachePath
    catch
        {}

writeCache = (c = cache) ->
    fs.outputJSON cachePath, c, space: 2
    .catch (e) ->
        console.log e

writeCacheSync = (c = cache) ->
    try
        fs.outputJSONSync cachePath, c, space: 2
    catch e
        console.log e

module.exports = {
    cache
    writeCache
    writeCacheSync
}
