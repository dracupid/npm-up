{ path, Promise } = fs = require 'nofs'
npm = require './npm'

isWin = process.platform is 'win32'
warnSign = if isWin then ' * Warning: ' else '⚠  '
errorSign = if isWin then ' ERROR: ' else '✖  '
okSign = if isWin then ' ^_^Y  ' else '✔  '

cwdFilePath = (names...) ->
    path.join.apply path, [process.cwd()].concat names

logInfo = (str) ->
    console.log '\n>>  '.yellow + str.green
logSucc = (str) ->
    console.log "\n#{okSign}#{str}".green

module.exports = {
    cwdFilePath
    errorSign
    warnSign
    okSign
    logSucc

    readPackageFile: (name) ->
        filePath = if name then cwdFilePath('node_modules', name, 'package.json') else cwdFilePath 'package.json'
        fs.readJSONSync filePath

    print: (deps, showWarn = true) ->
        deps.map (dep) ->
            dep.needUpdate and console.log "[#{dep.type}]".green, _.padRight(dep.packageName.cyan, 40),
                _.padLeft(dep.baseVer.toString(), 8).green, '->', dep.newVer.toString().red
            showWarn and dep.warnMsg and console.log warnSign.yellow + "#{dep.warnMsg}".white

    logInfo

    install: (packages) ->
        if packages.length is 0 then return Promise.resolve()
        logInfo "Start to install..."
        console.log packages.join(' ').cyan  + " will be updated".green

        Promise.promisify(npm.commands.i) packages
        .then ->
            logSucc "Latest version of the packages has been installed!".green

    curVer: do ->
        require('../package.json').version

    checkPrivilege: ->
        try
            fs.removeSync path.join __dirname, '*.temp'
            fs.linkSync __filename, path.join __dirname, 'linkTest.temp'
            true
        catch {errno}
            if errno is -13
                false
            else
                true
}
