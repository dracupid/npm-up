npm = require 'npm'
kit = require 'nokit'
{_, Promise} = kit

packageFile = kit.path.join process.cwd(), 'package.json'
packageBakFile = kit.path.join process.cwd(), 'package.bak.json'
modulesPath = kit.path.join process.cwd(), 'node_modules'

option = {}
globalPackage = {}

npmUp = (opts = {})->
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

    if option.all
        _.assign opts,
            writeBack: yes
            install: yes
            lock: yes

    option.exclude = _.compact option.exclude
    option.include and option.include = _.compact option.include

    if option.silent
        console.log = ->

    doUp()

readPackageFile = (name, onError)->
    path = if name then kit.path.join modulesPath, name, 'package.json' else packageFile
    try
        require path
    catch
        onError and onError path
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
        nerVer: ''
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
    kit.promisify(npm.commands.v)([dep.packageName, 'dist-tags.latest'], true)
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

doUp = ->
    deps = prepare()
    chain = kit.promisify(npm.load,
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
        if toUpdate.length is 0
            console.log "No package is updated.".green
            return

        chain = new Promise (resolve)->
            resolve()

        if option.writeBack
            chain.then ->
                _.forEach deps, (dep)->
                    toWrite = dep.newVer.verStr
                    if not option.lock then toWrite = dep.declareVer.prefix + toWrite
                    if not option.lock and dep.declareVer is '*' then toWrite = '*'

                    if dep.type is 'S'
                        globalPackage.dependencies[dep.packageName] = toWrite
                    if dep.type is 'D'
                        globalPackage.devDependencies[dep.packageName] = toWrite

                if option.backUp
                    if _.isString option.backUp
                        backFile = kit.join process.cwd(), option.backUp
                    else 
                        backFile = packageBakFile
                    kit.copy packageFile, backFile
            .then ->
                kit.writeFile packageFile, JSON.stringify globalPackage, null, 2 
            .then ->
                console.log "Package.json has been updated!".cyan

        if option.install
            chain.then ->
                console.log "#{toUpdate} will be updated".cyan
                kit.promisify(npm.commands.i)(toUpdate)
                .then ->
                    console.log "Newest version of the packages has been installed!".green
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

module.exports = npmUp