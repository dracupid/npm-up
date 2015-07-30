"use strict"

Module = require 'module'
path = require 'path'

cache = {}

readPackageFileCwd = (baseDir = '.') ->
    try
        require path.join baseDir, 'package.json'
    catch e
        if e instanceof SyntaxError
            throw e
        else
            err = new Error "cannot find package.json at #{baseDir} "
            err.code = 'ENOENT'
            throw err

module.exports.readPackageFile = (name = '', baseDir = '.') ->
    baseDir = path.resolve baseDir

    if res = cache[name + baseDir]
        return res

    cache[name + baseDir] = do ->
        if not name
            return readPackageFileCwd baseDir

        moduleDirs = Module._nodeModulePaths baseDir
        pack = null
        for dir in moduleDirs
            try
                return require path.join dir, name, 'package.json'

        e = new Error 'cannot find package.json for module ' + name
        e.code = 'ENOENT'
        throw e

module.exports.getPackageVersion = (name, baseDir) ->
    try
        module.exports.readPackageFile(name, baseDir).version
    catch e
        null
