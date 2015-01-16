require 'colors'
npm = require 'npm'
path = require 'path'
Promise = require 'bluebird'
_ = require 'lodash'
fs = require 'nofs'

packageFile = path.join process.cwd(), 'package.json'
packageBakFile = path.join process.cwd(), 'package.bak.json'
modulesPath = path.join process.cwd(), 'node_modules'

option = {}
globalPackage = {}

parseOpts = (opts)->
    option = _.defaults opts,
        include: "" # array
        exclude: [] # array
        writeBack: no
        install: no
        lock: no
        all: no # w + i + l
        devDep: yes
        dep: yes
        silent: no
        backUp: no
        lockAll: false

    if option.all
        _.assign opts,
            writeBack: yes
            install: yes
            lock: yes

    option.exclude = _.compact option.exclude
    option.include and option.include = _.compact option.include

    if option.silent
        console.log = ->

readPackageFile = (name, onError)->
    filePath = if name then path.join modulesPath, name, 'package.json' else packageFile
    try
        require filePath
    catch
        onError and onError filePath
        return null

parseVersion = (ver)->
    ver = ver.trim()
    if ver is '*' or ver is ''
        '*'
    else if /^[\D]?[\d\.]+\w*/.test ver
        new Version ver
    else
        null

parsePackage = (name, ver, type)->
    if _.isArray(option.include) and not (name in option.include)
        return null

    if name in option.exclude
        return null

    if type is 'g'
        declareVer = installedVer = new Version ver
    else
        # version in package.json
        declareVer = parseVersion ver
        if not declareVer then return null

        # version installed
        pack = readPackageFile name
        installedVer = if pack then new Version pack.version else null

    {
        packageName: name
        declareVer
        installedVer
        baseVer: installedVer
        newVer: ''
        type
        needUpdate: no
        warnMsg: ''
    }

formatPackages = (obj, type)->
    _.map obj, (version, name)->
        pack = parsePackage name, version, type

prepare = ()->
    globalPackage = readPackageFile null, ->
        console.log "ERROR: package.json Not Found".red
        process.exit 1

    deps = []
    if option.dep
        deps = deps.concat formatPackages globalPackage.dependencies, 'S'
    if option.devDep
        deps = deps.concat formatPackages globalPackage.devDependencies, 'D'

    deps = _.compact deps

getNewVersion = (dep) ->
    Promise.promisify(npm.commands.v)([dep.packageName, 'dist-tags.latest'], true)
    .then (data) ->
        dep.newVer = new Version _(data).keys().first()

        if dep.declareVer is '*'
            # '*' -> 'not installed'
            if not dep.installedVer
                dep.needUpdate = yes
                dep.baseVer =  dep.declareVer
                dep.warnMsg = "package #{dep.packageName} is not installed."
            # '*' -> 'x.x.x'
            else
                dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0
        else
            # 'X.X.X' -> 'not installed'
            if not dep.installedVer
                dep.needUpdate = dep.declareVer.compareTo(dep.newVer) < 0
                dep.baseVer =  dep.declareVer
                dep.warnMsg = "package #{dep.packageName} is not installed."

            # 'X.X.X' -> 'X.X.X'
            else
                dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0
                if dep.installedVer.compareTo(dep.declareVer) isnt 0
                    dep.warnMsg = "version info for #{dep.packageName} can be updated. Installed #{dep.installedVer}, declare #{dep.declareVer}"
        dep

print = (deps)->
    _.map deps, (dep)->
        dep.needUpdate and console.log '>> ', dep.packageName.cyan, '\t',
            dep.baseVer.toString().green, '->', dep.newVer.toString().red
        dep.warnMsg and console.log "WARN: #{dep.warnMsg}".grey

npmUp = (opts = {})->
    parseOpts opts

    deps = prepare()

    Promise.promisify(npm.load,
        loaded: false
    )()
    .then ->
        console.log 'Checking npm update...'.green
        Promise.all _.map deps, getNewVersion
    .then (newDeps)->
        deps = newDeps
        print deps
        console.log 'Check npm update done!'.green
    .then ->
        toUpdate = _.map(_.filter(deps, (dep)->dep.needUpdate and dep.installedVer),
            (dep)->"#{dep.packageName}@#{dep.newVer}")

        chain = new Promise (resolve)->
            resolve()

        if option.writeBack
            chain.then ->
                _.forEach deps, (dep)->
                    toWrite = dep.newVer.verStr
                    if not option.lock then toWrite = (dep.declareVer.prefix or '')+ toWrite
                    if !option.lockAll and dep.declareVer is '*' then toWrite = '*'

                    if dep.type is 'S'
                        globalPackage.dependencies[dep.packageName] = toWrite
                    if dep.type is 'D'
                        globalPackage.devDependencies[dep.packageName] = toWrite

                if option.backUp
                    if _.isString option.backUp
                        backFile = path.join process.cwd(), option.backUp
                    else
                        backFile = packageBakFile
                    fs.copyP packageFile, backFile
            .then ->
                fs.writeFileP packageFile, JSON.stringify(globalPackage, null, 2) + '\n'
            .then ->
                console.log "Package.json has been updated!".cyan

        if option.install
            if toUpdate.length isnt 0
                chain.then ->
                    console.log "#{toUpdate} will be updated".cyan
                    Promise.promisify(npm.commands.i)(toUpdate)
                    .then ->
                        console.log "Newest version of the packages has been installed!".green
            else
              console.log "No package is updated.".green
        chain

class Version
    constructor: (verStr)->
        arr = /^([\D])?([\d\.]+)(.*)/.exec verStr
        @prefix = arr[1] or ''
        @verStr = arr[2]
        @version = arr[2].split '.'
        @suffix = arr[3]
        @

    toString: ()->
        @prefix + @version.join('.') + @suffix

    compareTo: (ver)->
        arr = _.zip @version, ver.version
        for i in arr
            if i[0] is i[1] then continue
            else if _.isUndefined i[0] then return -1
            else if _.isUndefined i[1] then return 1
            else return parseInt(i[0], 10) - parseInt(i[1], 10)
        return 0

npmUpGlobal = (opts)->
    parseOpts opts

    Promise.promisify(npm.load,
        loaded: false
    )()
    .then ->
        console.log 'Reading global packages...'.green
        npm.config.set 'global', true
        # known issue: only the first dir will be listed in PATH
        Promise.promisify(npm.commands.ls)(null, true)
    .then (data) ->
        globalDep = data.dependencies or data[0].dependencies
        console.log "Following packages are found: " + ((_.keys globalDep) + '').cyan
        deps = _.map globalDep, (val, key)->
            parsePackage key, val.version, 'g'
        console.log 'Checking npm update...'.green
        Promise.all _.map _.compact(deps), getNewVersion
    .then (newDeps)->
        deps = newDeps
        print deps
        console.log 'Check npm update done!'.green

        toUpdate = _.map(_.filter(deps, (dep)->dep.needUpdate and dep.installedVer),
            (dep)->"#{dep.packageName}@#{dep.newVer}")
        if toUpdate.length is 0
            console.log "No package is updated.".green
            return

        chain = new Promise (resolve)->
            resolve()

        if option.install
            chain.then ->
                console.log "#{toUpdate} will be updated".cyan
                npm.config.set 'global', true
                Promise.promisify(npm.commands.i)(toUpdate)
                .then ->
                    console.log "Newest version of the packages has been installed!".green
        chain

module.exports = npmUp
module.exports.npmUpGlobal = npmUpGlobal
