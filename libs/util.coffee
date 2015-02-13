path = require 'path'
Promise = require 'bluebird'
npm = require 'npm'

isWin = process.platform is 'win32'
warnSign = if isWin then ' * Warning: ' else '⚠ '
errorSign = if isWin then ' ERROR: ' else '✖ '
okSign = if isWin then '' else '✔ '

cwdFilePath = (names...)->
    path.join.apply path, [process.cwd()].concat names

logInfo = (str)->
    console.log '\n>>  '.yellow + str.green

module.exports = {
    cwdFilePath
    errorSign
    warnSign
    okSign

    readPackageFile: (name, onError)->
        filePath = if name then cwdFilePath('node_modules', name, 'package.json') else cwdFilePath 'package.json'
        try
            require filePath
        catch
            onError and onError filePath
            null

    print: (deps)->
        deps.map (dep)->
            dep.needUpdate and console.log "[#{dep.type}]".green, _.padRight(dep.packageName.cyan, 40),
                dep.baseVer.toString().green, '->', dep.newVer.toString().red
            dep.warnMsg and console.log warnSign.yellow + "#{dep.warnMsg}".white

    logInfo

    install: (packages)->
        if packages.length is 0 then return Promise.resolve()
        logInfo "Start to install..."
        console.log packages.join(' ').cyan  + " will be updated".green

        Promise.promisify(npm.commands.i) packages
        .then ->
            logInfo "Latest version of the packages has been installed!".green

    curVer: do ->
        require('../package.json').version
}
