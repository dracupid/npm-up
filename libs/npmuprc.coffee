path = require 'path'
fs = require 'nofs'

home = if process.platform is 'win32' then process.env.USERPROFILE else process.env.HOME
rcFile = path.join home, '.npmuprc.json'


npmuprc = do ->
    try
        require rcFile
    catch
        {}

writeRC = (rc = npmuprc)->
    fs.outputJSON rcFile, rc, space: 2
    .catch (e)->
        console.log e

module.exports = {
    npmuprc
    writeRC
}
