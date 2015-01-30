path = require 'path'
Version = require './Version'

cwdFilePath = (names...)->
    path.join.apply path, [process.cwd()].concat names

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
            dep.needUpdate and console.log '>> ', dep.packageName.cyan, '\t',
                dep.baseVer.toString().green, '->', dep.newVer.toString().red
            dep.warnMsg and console.log "WARN: #{dep.warnMsg}".grey

    parseVersion: (ver)->
        ver = ver.trim()
        if ver is '*' or ver is ''
            '*'
        else if /^[\D]?[\d\.]+\w*/.test ver
            new Version ver
        else
            null
}
