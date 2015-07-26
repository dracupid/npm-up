"use strict"

{path, Promise} = fs = require 'nofs'
Module = require 'module'
chalk = require 'chalk'
nodeModulesPaths = Module._nodeModulePaths process.cwd()

isWin = process.platform is 'win32'
warnSign = if isWin then '‼ ' else '⚠  '
errorSign = if isWin then '× ' else '✖  '
okSign = if isWin then '√  ' else '✔  '
infoSign = if isWin then 'i ' else 'ℹ '

cwdFilePath = (names...) ->
    path.join.apply path, [process.cwd()].concat names

logInfo = (str) ->
    console.log chalk.bold chalk.yellow('\n>> ') + chalk.green(str)
logSucc = (str) ->
    console.log chalk.green.bold "\n#{okSign}#{str}"
logWarn = (str) ->
    console.log chalk.grey chalk.yellow(warnSign) + str

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

    getRegistry: (name) ->
        name = name.trim()
        if name is '' then ''
        else if host[name] then host[name]
        else if protocolReg.test name
            name
        else
            'http://' + name

    print: (deps, showWarn = true) ->
        deps.map (dep) ->
            dep.needUpdate and console.log chalk.green("[#{dep.type}]"), padRight(chalk.cyan.bold(dep.packageName), 40),
                chalk.red(padLeft(dep.baseVer.toString(), 8)), '->', chalk.green(dep.newVer.toString())
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

    allPackagesIn: (dir) ->
        fs.glob path.join dir, '*/package.json'
        .then (files) ->
            files.map (f) ->
                try require f
                catch
                    null
            .filter (f) -> not not f

    promisify: fs.PromiseUtils.promisify
}
