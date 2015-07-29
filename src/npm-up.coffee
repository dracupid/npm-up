"use strict"

chalk = require 'chalk'
{path, Promise: global.Promise} = fs = require 'nofs'
global._ = require 'underscore'
semver = require 'semver'

npm = require './npm'
util = require './util'
checkVer = require './checkVersion'
packageMgr = require './package'

option = {}
globalPackage = {}

parseOpts = (opts = {}) ->
    _.defaults opts,
        include: "", exclude: [] # array
        writeBack: no
        install: no
        lock: no
        all: no # w + i + l
        devDep: yes, dep: yes, optional: yes
        silent: no
        lockAll: false
        cache: true
        logLevel: 'error'
        cwd: process.cwd()
        warning: true
        mirror: ''

    opts.mirror = util.getRegistry opts.mirror

    opts.all and
        _.assign opts,
            writeBack: yes
            install: yes
            lock: yes

    opts.exclude = _.compact opts.exclude
    opts.include and opts.include = _.compact opts.include

    opts

parsePackage = (name, ver, type) ->
    if Array.isArray(option.include) and not (name in option.include)
        return null

    if name in option.exclude
        return null

    if type is 'g'
        declareVer = installedVer = ver
    else
        # version in package.json
        declareVer = if semver.validRange ver then ver.trim() else null
        declareVer is '' and declareVer = '*'
        return null unless declareVer

        # version installed
        installedVer = packageMgr.getPackageVersion name

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

formatPackages = (obj, type) ->
    _.map obj, (version, name) ->
        parsePackage name, version, type

prepare = ->
    try
        globalPackage = packageMgr.readPackageFile()
    catch e
        throw new Error (
            if e instanceof SyntaxError
                'unvalid package.json!'
            else
                'package.json Not Found!'
        )

    deps = []
    if option.dep
        deps = deps.concat formatPackages globalPackage.dependencies, 'S'
    if option.devDep
        deps = deps.concat formatPackages globalPackage.devDependencies, 'D'
    if option.optional
        deps = deps.concat formatPackages globalPackage.optionalDependencies, 'O'

    deps = _.compact deps

getToWrite = ({declareVer, newVer}, {lock, lockAll}) ->
    if declareVer in ['*', '']
        return if lockAll then newVer else '*'

    prefix =
        if lock or semver.valid declareVer
            ''
        else if m = declareVer.match /^([><=\s]+)[\d\w.-\s]*$/
            m[1]
        else '^'

    prefix + newVer

npmUp = ->
    process.chdir option.cwd

    try
        deps = prepare()
    catch e
        console.error chalk.red (util.errorSign + " #{e}")
        return Promise.reject()

    util.logInfo 'Checking packages\' version...'
    checkVer deps, option.cache, option.mirror
    .then (newDeps) ->
        deps = newDeps
        util.print deps, option.warning

        toUpdate = deps.filter (dep) -> dep.needUpdate and dep.installedVer
                        .map (dep) -> "#{dep.packageName}@#{dep.newVer}"

        chain = Promise.resolve()

        if toUpdate.length is 0
            util.logSucc "Everything is new!"

        if option.writeBack
            packageFile = util.cwdFilePath 'package.json'

            chain = chain.then ->
                deps.forEach (dep) ->
                    toWrite = getToWrite dep, option

                    switch dep.type
                        when 'S' then globalPackage.dependencies[dep.packageName] = toWrite
                        when 'D' then globalPackage.devDependencies[dep.packageName] = toWrite
                        when 'O' then globalPackage.optionalDependencies[dep.packageName] = toWrite
            .then ->
                ['dependencies', 'devDependencies', 'optionalDependencies'].forEach (k) ->
                    delete globalPackage[k] if _.isEmpty globalPackage[k]
                fs.outputJSON packageFile, globalPackage, space: 2
            .then ->
                util.logSucc "package.json has been updated!"

        if option.install
            install = require './install'
            chain = chain.then ->
                install toUpdate, option.cwd

        chain

npmUpSubDir = ->
    process.chdir option.cwd

    fs.glob '*/package.json'
    .then (packs) ->
        packs.reduce (prev, cur) ->
            cwd = process.cwd()
            dir = path.dirname cur
            prev.then ->
                console.log '\n', path.basename dir
                option.cwd = path.join cwd, dir
                npmUp()
            .catch -> return
        , Promise.resolve()


npmUpGlobal = ->
    if option.install and not util.checkPrivilege()
        console.error chalk.red (util.errorSign + " Permission Denied")
        console.error chalk.yellow "Please try running this command again as root/Administrator"
        process.exit 1

    util.logInfo 'Searching global packages...'

    # In npm@3, global modules is not flatten.
    util.allPackagesIn npm.globalDir
    .then (packages) ->
        globalDep = packages.reduce (obj, pack) ->
            obj[pack.name] = pack.version
            obj
        , {}
        console.log chalk.cyan Object.keys(globalDep).join ' '

        deps = _.map globalDep, (val, key) ->
            parsePackage key, val, 'g'
        util.logInfo 'Checking packages\' version...'

        checkVer _.compact(deps), option.cache, option.mirror
    .then (newDeps) ->
        deps = newDeps
        util.print deps, option.warning

        toUpdate = deps.filter (dep) -> dep.needUpdate and dep.installedVer
                    .map (dep) -> "#{dep.packageName}@#{dep.newVer}"

        if toUpdate.length is 0
            util.logSucc "Everything is new!"
            Promise.resolve()
        else if option.install
            oldLen = toUpdate.length
            toUpdate = toUpdate.filter (name) ->
                name.indexOf('npm@') isnt 0

            if oldLen isnt toUpdate.length
                util.logWarn chalk.yellow "It may cause a broken error to install npm by npm-up sometimes.",
                    "Please use", chalk.cyan("[sudo] npm i npm -g"), "instead."
                console.log chalk.green "   If you know the reason, please put forward an issue."

            require('./install') toUpdate

module.exports = (opt, checkUpdate = false) ->
    option = parseOpts opt

    npmOpt =
        loglevel: option.logLevel
        global: not not opt.global

    if option.mirror
        npmOpt.registry = option.mirror

    util.promisify(npm.load) npmOpt
    .then ->
        option.mirror = npm.config.get('registry')[..-2]
        promise =
            if opt.global then npmUpGlobal()
            else if opt.All then npmUpSubDir()
            else npmUp()
        if checkUpdate
            p = require('./updateSelf')(option.mirror)
            promise.then -> p.log()
