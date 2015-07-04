"use strict"

{path, Promise} = fs = require 'nofs'

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
logWarn = (str) ->
    console.log warnSign.yellow + str.white

host =
    npm: 'http://registry.npmjs.org'
    taobao: 'http://registry.npm.taobao.org'
    cnpmjs: 'http://r.cnpmjs.org'

protocolReg = /^https?:\/\//

module.exports = {
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

    readPackageFile: (name) ->
        filePath = if name then cwdFilePath('node_modules', name, 'package.json') else cwdFilePath 'package.json'
        require filePath

    print: (deps, showWarn = true) ->
        deps.map (dep) ->
            dep.needUpdate and console.log "[#{dep.type}]".green, _.padRight(dep.packageName.cyan, 40),
                _.padLeft(dep.baseVer.toString(), 8).green, '->', dep.newVer.toString().red
            showWarn and dep.warnMsg and logWarn "#{dep.warnMsg}"

    debug: ->
        if process.env.DEBUG in [true, 'on', 'true']
            console.log arguments...

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
