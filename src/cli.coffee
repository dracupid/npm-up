"use strict"

cmder = require 'commander'

cmder
    .usage "[command] [options]"
    .version require('./util').curVer
cmder
    .command 'clean'
    .description 'clean cache'
    .action ->
        {writeCacheSync} = require './data'
        writeCacheSync {}
        process.exit 0
cmder
    .command 'dump'
    .description 'dump cache'
    .action ->
        chalk = require 'chalk'
        util = require 'util'
        {cache, cachePath} = require './data'
        console.log chalk.bold chalk.yellow('Cache path:'), chalk.magenta(cachePath)
        console.log util.inspect (cache.verCache or {}), colors: yes
        process.exit 0
cmder
    .option '-g, --global', "Check global packages"
    .option '-A, --All', "Check all projects in sub directories, depth is 1"
    .option '-w, --writeBack', "Write updated version back to package.json"
    .option '-i, --install', "Install the latest version of the packages"
    .option '-l, --lock', "Use specific versions in package.json, with no ranges. (except *)"
    .option '--lock-all', "Lock, even for * version"
    .option '-a, --all', "Shortcut for -wil"
    .option '-m, --mirror <mirror host or name>', "Use a mirror registry host"
    .option '--no-cache', "Disable version cache"
    .option '--no-warning', "Disable warning"
    .option '-d, --dep', "Check dependencies only"
    .option '-D, --dev', "Check devDependencies only"
    .option '-O, --optional', "Check optionalDependencies only"
    .option '-c, --cwd <cwd>', "Set current working directory"
    .option '-L, --logLevel <level>', "Set loglevel for npm, default is error"
    .option '-t, --tag <tag>', "Dist-tag used as the version to be updated"
    .option '-e, --exclude <list>', "Excluded packages list, split by comma or space",
        (list) -> list.split /,|\s/
    .option '-o, --only <list>', "Included packages list, split by comma or space",
        (list) -> list.split /,|\s/
    .option '-p --exclude-locked', "Exclude all locked packages"

cmder.parse process.argv

opts = do (cmder) ->
    opts = cmder
    opts.lock = cmder.lock or cmder.lockAll
    cmder.exclude and opts.exclude = cmder.exclude
    cmder.only and opts.include = cmder.only

    depNames = ['dep', 'dev', 'optional']
    res = depNames.reduce (res, cur) ->
        res = res or cmder[cur]
    , false

    if res then depNames.forEach (name) -> opts[name] = not not cmder[name]
    else depNames.forEach (name) -> opts[name] = not cmder[name]

    opts

require('./npm-up') opts, true
.catch (e) ->
    if e then console.error e.stack or e
    process.exit 1
