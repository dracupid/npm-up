npm = require 'npm'
kit = require 'nokit'
{_, Promise} = kit
try
    pack = require kit.path.join process.cwd(), './package.json'
catch
    kit.err "[404] package.json Not Found".red

format = (obj, type)->
    _.map obj, (v, k)->
        packageName: k
        curVer: /\D?([\d\.]*)\w*/.exec(v)[1]
        newVer: ''
        type: type
        needUpdate: no

deps = format(pack.dependencies, 'S').concat format(pack.devDependencies, 'D')

getNewVersion = (dep) ->
    Promise.promisify(npm.commands.v)([dep.packageName, 'dist-tags.latest'], true)
    .then (data) ->
        dep.newVer = _(data).keys().first()
        if dep.type is 'S'
            pack.dependencies[dep.packageName] = dep.newVer
        else
            pack.devDependencies[dep.packageName] = dep.newVer
        if dep.newVer isnt dep.curVer then dep.needUpdate = yes

print = ()->
    _.map deps, (dep)->
       dep.needUpdate and console.log '>> ', dep.packageName.yellow, ': ', dep.curVer.green, '->', dep.newVer.red     

module.exports = 
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
