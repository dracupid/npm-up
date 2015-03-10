{ path, Promise } = fs = require 'nofs'

isWin = process.platform is 'win32'
warnSign = if isWin then '‼ ' else '⚠  '
errorSign = if isWin then '× ' else '✖  '
okSign = if isWin then '√  ' else '✔  '
infoSign = if isWin then 'i ' else 'ℹ '

cwdFilePath = (names...) ->
    path.join.apply path, [process.cwd()].concat names

logInfo = (str) ->
    console.log '\n>> '.yellow + str.green
logSucc = (str) ->
    console.log "\n#{okSign}#{str}".green

host =
    npm: 'registry.npmjs.org'
    taobao: 'registry.npm.taobao.org'
    cnpmjs: 'r.cnpmjs.org'
    skimdb: 'skimdb.npmjs.com/registry'

module.exports = {
    cwdFilePath
    errorSign
    warnSign
    okSign
    logSucc

    getRegistry: (name) ->
        host[name] or name

    readPackageFile: (name) ->
        filePath = if name then cwdFilePath('node_modules', name, 'package.json') else cwdFilePath 'package.json'
        fs.readJSONSync filePath

    print: (deps, showWarn = true) ->
        deps.map (dep) ->
            dep.needUpdate and console.log "[#{dep.type}]".green, _.padRight(dep.packageName.cyan, 40),
                _.padLeft(dep.baseVer.toString(), 8).green, '->', dep.newVer.toString().red
            showWarn and dep.warnMsg and console.log warnSign.yellow + "#{dep.warnMsg}".white

    logInfo

    curVer: do ->
        require('../package.json').version

    checkPrivilege: ->
        try
            fs.linkSync __filename, path.join __dirname, 'linkTest.temp'
            fs.removeSync path.join __dirname, '*.temp'
            true
        catch {errno}
            if errno is -13
                false
            else
                true
}
