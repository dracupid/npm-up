"use strict"

{path, Promise} = fs = require 'nofs'
Module = require 'module'
nodeModulesPaths = Module._nodeModulePaths process.cwd()

isWin = process.platform is 'win32'
warnSign = if isWin then '‼ ' else '⚠  '
errorSign = if isWin then '× ' else '✖  '
okSign = if isWin then '√  ' else '✔  '
infoSign = if isWin then 'i ' else 'ℹ '

cwdFilePath = (names...) ->
    path.join.apply path, [process.cwd()].concat names

logInfo = (str) ->
    console.log '\n>> '.yellow.bold + str.green.bold
logSucc = (str) ->
    console.log "\n#{okSign}#{str}".green.bold
logWarn = (str) ->
    console.log warnSign.yellow.bold + str.white.bold

host =
    npm: 'http://registry.npmjs.org'
    taobao: 'http://registry.npm.taobao.org'
    cnpmjs: 'http://r.cnpmjs.org'

protocolReg = /^https?:\/\//

repeat = (str, n) ->
    n = parseInt n
    res = ''
    return res if n < 1
    for i in [0..n]
        res += str
    res

padRight = (str, n) ->
    str += ''
    strLen = str.length
    if strLen >= n then str else str + repeat ' ', n - strLen

padLeft = (str, n) ->
    str += ''
    strLen = str.length
    if strLen >= n then str else repeat(' ', n - strLen) + str

debug = ->
    if process.env.DEBUG in [true, 'on', 'true']
        console.log arguments...

module.exports = {
    debug
    cwdFilePath
    errorSign
    warnSign
    okSign
    logInfo
    logSucc
    logWarn

    getRegistry: (name = 'npm') ->
        name = name.trim()
        if host[name] then host[name]
        else if protocolReg.test name
            name
        else
            'http://' + name

    print: (deps, showWarn = true) ->
        deps.map (dep) ->
            dep.needUpdate and console.log "[#{dep.type}]".green, padRight(dep.packageName.cyan, 40),
                padLeft(dep.baseVer.toString(), 8).green, '->', dep.newVer.toString().red
            showWarn and dep.warnMsg and logWarn "#{dep.warnMsg}"

    curVer: do ->
        require('../package.json').version

    checkPrivilege: ->
        try
            fs.linkSync __filename, path.join __dirname, 'linkTest.temp'
            fs.removeSync path.join __dirname, '*.temp'
            true
        catch {errno}
            errno isnt -13

    promisify: fs.PromiseUtils.promisify
}
