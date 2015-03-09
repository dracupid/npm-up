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

writeCache = (rc = cache) ->
    fs.outputJSON cachePath, rc, space: 2
    .catch (e) ->
        console.log e

writeCacheSync = (rc = cache) ->
    fs.outputJSONSync cachePath, rc, space: 2
    .catch (e) ->
        console.log e

module.exports = {
    cache
    writeCache
    writeCacheSync
}
