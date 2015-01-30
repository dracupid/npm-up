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
    obj.map (version, name)->
        pack = parsePackage name, version, type

prepare = ()->
    globalPackage = util.readPackageFile null, ->
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


npmUp = ->
    deps = prepare()

    Promise.promisify(npm.load)
        loglevel: 'error'
    .then ->
        console.log 'Checking npm update...'.green
        Promise.all _.map deps, getNewVersion
    .then (newDeps)->
        deps = newDeps
        util.print deps
        console.log 'Check npm update done!'.green
    .then ->
        toUpdate = _.map(_.filter(deps, (dep)->dep.needUpdate and dep.installedVer),
            (dep)->"#{dep.packageName}@#{dep.newVer}")

        chain = new Promise (resolve)->
            resolve()

        if option.writeBack
            chain.then ->
                deps.forEach (dep)->
                    toWrite = dep.newVer.verStr + dep.newVer.suffix
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
                    fs.copy packageFile, backFile
            .then ->
                fs.writeFile packageFile, JSON.stringify(globalPackage, null, 2) + '\n'
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

npmUpGlobal = ->
    Promise.promisify(npm.load)
        loglevel: 'error'
        global: true
    .then ->
        console.log 'Reading global packages...'.green
        # known issue: only the first dir will be listed in PATH
        Promise.promisify(npm.commands.ls) null, true
    .then (data) ->
        globalDep = data.dependencies or data[0].dependencies
        console.log "Following packages are found: " + ((_.keys globalDep) + '').cyan
        deps = globalDep.map (val, key)->
            parsePackage key, val.version, 'g'
        console.log 'Checking npm update...'.green
        Promise.all _.map _.compact(deps), getNewVersion
    .then (newDeps)->
        deps = newDeps
        util.print deps
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

module.exports = (opt, type)->
    parseOpts opt

    promise = if type is 'global' then npmUpGlobal() else npmUp()

    promise.catch (e)->
        console.error e
        process.exit 1


