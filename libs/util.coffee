path = require 'path'
Version = require './Version'
Promise = require 'bluebird'
npm = require 'npm'

cwdFilePath = (names...)->
    path.join.apply path, [process.cwd()].concat names

logInfo = (str)->
    console.log '\n>>  '.yellow + str.green

module.exports = {
    cwdFilePath

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
            dep.warnMsg and console.log " *  Warning: ".yellow + "#{dep.warnMsg}".white

    parseVersion: (ver)->
        ver = ver.trim()
        if ver is '*' or ver is ''
            '*'
        else if /^[\D]?[\d\.]+\w*/.test ver
            new Version ver
        else
            null

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
