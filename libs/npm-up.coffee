npm = require 'npm'
kit = require 'nokit'
{_, Promise} = kit
try
    pack = require kit.path.join process.cwd(), './package.json'
catch
    kit.err "[404] package.json Not Found".red
    process.exit 0

versionFilter = (ver)->
    if ver is '*' or ver is ''
        return '*'
    else
        return /\D?([\d\.\*]*)\w*/.exec(ver)[1]

format = (obj, type)->
    _.map obj, (v, k)->
        path = kit.path.join process.cwd(), "./node_modules/#{k}/package.json"
        curVer = versionFilter v
        try 
            installedVer = require(path).version
        catch
            installedVer = if curVer is '*' then 'not installed' else curVer

        curVer is '*' and curVer = installedVer

        packageName: k
        curVer: curVer
        installedVer: installedVer
        newVer: ''
        type: type
        needUpdateJSON: no
        needUpdate: no
        packagePath: path

deps = format(pack.dependencies, 'S').concat format(pack.devDependencies, 'D')

getNewVersion = (dep) ->
    Promise.promisify(npm.commands.v)([dep.packageName, 'dist-tags.latest'], true)
    .then (data) ->
        dep.newVer = _(data).keys().first()
        if dep.type is 'S'
            pack.dependencies[dep.packageName] = dep.newVer
        else
            pack.devDependencies[dep.packageName] = dep.newVer

        if dep.installedVer isnt dep.curVer then dep.needUpdateJSON = yes
        if dep.newVer isnt dep.installedVer then dep.needUpdate = yes

print = ()->
    _.map deps, (dep)->
        dep.needUpdate and console.log '>> ', dep.packageName.yellow, ': ', dep.installedVer.green, '->', dep.newVer.red
        if not dep.needUpdate and dep.needUpdateJSON 
            console.log ">> Your package.json can be updated: ", dep.packageName.yellow, ': ', dep.curVer.green, '->', dep.installedVer.red

# module.exports = 
Promise.promisify(npm.load,
    loaded: false
)()
.then ->
    console.log 'Checking npm update...'.green
.then ->
   Promise.all _.map deps, getNewVersion
.done ->
    print()
    console.log 'Check update done.'.green
