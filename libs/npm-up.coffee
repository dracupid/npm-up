require 'colors'
npm = require 'npm'
path = require 'path'
Promise = require 'bluebird'
_ = require 'lodash'
fs = require 'nofs'

Version = require './Version'
util = require './util'

packageFile = util.cwdFilePath 'package.json'
packageBakFile = util.cwdFilePath 'package.bak.json'
modulesPath = util.cwdFilePath 'node_modules'

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

parsePackage = (name, ver, type)->
    if Array.isArray(option.include) and not (name in option.include)
        return null

    if name in option.exclude
        return null

    if type is 'g'
        declareVer = installedVer = new Version ver
    else
        # version in package.json
        declareVer = util.parseVersion ver
        if not declareVer then return null

        # version installed
        pack = util.readPackageFile name
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
    globalPackage = util.readPackageFile null, ->
        console.error "ERROR: package.json Not Found".red
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
                dep.warnMsg = "#{dep.packageName.cyan} is not installed."
            # '*' -> 'x.x.x'
            else
                dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0
        else
            # 'X.X.X' -> 'not installed'
            if not dep.installedVer
                dep.needUpdate = dep.declareVer.compareTo(dep.newVer) < 0
                dep.baseVer =  dep.declareVer
                dep.warnMsg = "#{dep.packageName.cyan} is not installed."

            # 'X.X.X' -> 'X.X.X'
            else
                dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0
                if dep.installedVer.compareTo(dep.declareVer) < 0
                    dep.warnMsg = "Installed #{dep.packageName.cyan} is outdated:" +
                        " Installed #{(dep.installedVer + '').red} --> Declared #{(dep.declareVer + '').green}"
                else if dep.installedVer.compareTo(dep.declareVer) > 0
                    dep.warnMsg = "You may want to update #{dep.packageName.cyan}\'s version info:" +
                        " Installed #{(dep.installedVer + '').red} --> Declared #{(dep.declareVer + '').green}"
        dep


npmUp = ->
    deps = prepare()

    Promise.promisify(npm.load)
        loglevel: 'error'
    .then ->
        util.logInfo 'Checking package\'s version...'
        Promise.all _.map deps, getNewVersion
    .then (newDeps)->
        deps = newDeps
        util.print deps

        toUpdate = _.map(_.filter(deps, (dep)->dep.needUpdate and dep.installedVer),
            (dep)->"#{dep.packageName}@#{dep.newVer}")

        if toUpdate.length is 0
            util.logInfo "Everything is new!"
            return

        chain = Promise.resolve()

        if option.writeBack
            chain.then ->
                deps.forEach (dep)->
                    toWrite = dep.newVer.verStr + dep.newVer.suffix
                    unless option.lock then toWrite = (dep.declareVer.prefix or '') + toWrite
                    if !option.lockAll and dep.declareVer is '*' then toWrite = '*'

                    switch dep.type
                        when 'S' then globalPackage.dependencies[dep.packageName] = toWrite
                        when 'D' then globalPackage.devDependencies[dep.packageName] = toWrite

                if option.backUp
                    backFile = if _.isString option.backUp then util.cwdFilePath option.backUp else packageBakFile
                    fs.copy packageFile, backFile
            .then ->
                fs.outputJSON packageFile, globalPackage, space: 2
            .then ->
                util.logInfo "package.json has been updated!"

        if option.install then util.install toUpdate

npmUpGlobal = ->
    Promise.promisify(npm.load)
        loglevel: 'error'
        global: true
    .then ->
        util.logInfo 'Reading global installed packages...'
        # known issue: only the first dir will be listed in PATH
        Promise.promisify(npm.commands.ls) null, true
    .then (data) ->
        globalDep = data.dependencies or data[0].dependencies
        console.log ((_.keys globalDep).join ' ').cyan

        deps = _.map globalDep, (val, key)->
            parsePackage key, val.version, 'g'
        util.logInfo 'Checking package\'s version...'

        Promise.all _.map _.compact(deps), getNewVersion
    .then (newDeps)->
        deps = newDeps
        util.print deps

        toUpdate = _.map(_.filter(deps, (dep)->dep.needUpdate and dep.installedVer),
            (dep)->"#{dep.packageName}@#{dep.newVer}")

        if toUpdate.length is 0
            util.logInfo "Everything is new!"
            return

        if option.install then util.install toUpdate

module.exports = (opt, type)->
    parseOpts opt

    promise = if type is 'global' then npmUpGlobal() else npmUp()

    promise.catch (e)->
        throw e
        process.exit 1


