cmder = require 'commander'
util = require './util'
checkUpdate = require './updateSelf'
{npmuprc, writeRC} = require './npmuprc'

cmder
    .usage "[command] [options]"
    .command 'clean'
    .description 'clean cache'
    .action ->
        writeRCSync {}
        process.exit 0
cmder
    .command 'dump'
    .description 'dump cache'
    .action ->
        console.log npmuprc
        process.exit 0
cmder
    .option '-v, --ver', "Current version of npm-up."
    .option '-g, --global', "Check global packages."
    .option '-A, --ALL', "Check all projects in sub directories, depth is 1."
    .option '-w, --writeback', "Write updated version info back to package.json."
    .option '-i, --install', "Install the latest version of the packages need to be updated."
    .option '-l, --lock', "Lock the version of the package in package.json, with no version prefix."
    .option '--lock-all', "Lock, even with * version."
    .option '-a, --all', "Shortcut for -wil."
    .option '--no-cache', "Disable version cache."
    .option '-b, --backup [fileName]', "Back up package.json before writing back, default name is package.bak.json."
    .option '-d, --dep', "Check dependencies only."
    .option '-D, --dev', "Check devDependencies only."
    .option '-s, --silent', "Do not print any infomation."
    .option '-c, --cwd <cwd>', "Current working directory."
    .option '-L, --logLevel <level>', "Set loglevel for npm, default is error"
    .option '-e, --exclude <list>', "Excluded packages list, split by comma.",
        (list) -> list.split ','
    .option '-o, --only <list>', "Included packages list, split by comma.",
        (list) -> list.split ','

cmder.parse process.argv

init = (cmder) ->
    opts = cmder
    opts.lock = cmder.lock or cmder.lockAll
    cmder.dep and opts.devDep = no
    cmder.dev and opts.dep = no
    cmder.exclude and opts.exclude = cmder.exclude
    cmder.only and opts.include = cmder.only

    if cmder.dep and cmder.dev
        opts.devDep = ops.dep = yes
    opts

if cmder.ver
    console.log util.curVer
else
    checkUpdate().then (a) ->
        opts = init cmder
        if cmder.global
            require('./npm-up') opts, 'global'
        else if cmder.ALL
            require('./npm-up') opts, 'subDir'
        else
            require('./npm-up') opts
    .catch (e) ->
        if e then console.error e.stack or e
        process.exit 1
