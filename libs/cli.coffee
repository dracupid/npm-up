cmder = require 'commander'
{cache, writeCacheSync, cachePath} = require './data'

cmder
    .usage "[command] [options]"
    .version require('./util').curVer
cmder
    .command 'clean'
    .description 'clean cache'
    .action ->
        writeCacheSync {}
        process.exit 0
cmder
    .command 'dump'
    .description 'dump cache'
    .action ->
        require 'colors'
        console.log "npm-up cache: ".cyan + cachePath.yellow
        console.log cache.verCache or ''
        process.exit 0
cmder
    .option '-g, --global', "Check global packages."
    .option '-A, --All', "Check all projects in sub directories, depth is 1."
    .option '-w, --writeBack', "Write updated version info back to package.json."
    .option '-i, --install', "Install the latest version of the packages need to be updated."
    .option '-l, --lock', "Lock the version of the package in package.json, with no version prefix."
    .option '--lock-all', "Lock, even with * version."
    .option '-a, --all', "Shortcut for -wil."
    .option '-m, --mirror <mirror host or name>', "Use a mirror registry server."
    .option '--no-cache', "Disable version cache."
    .option '--no-warning', "Disable warning."
    .option '-b, --backup [fileName]', "Back up package.json before writing back, default name is package.bak.json."
    .option '-d, --dep', "Check dependencies only."
    .option '-D, --dev', "Check devDependencies only."
    .option '-s, --silent', "Do not print any infomation."
    .option '-c, --cwd <cwd>', "Current working directory."
    .option '-L, --logLevel <level>', "Set loglevel for npm, default is error"
    .option '-e, --exclude <list>', "Excluded packages list, split by comma or space.",
        (list) -> list.split /,|\s/
    .option '-o, --only <list>', "Included packages list, split by comma or space.",
        (list) -> list.split /,|\s/

cmder.parse process.argv

opts = do (cmder) ->
    opts = cmder
    opts.lock = cmder.lock or cmder.lockAll
    cmder.dep and opts.devDep = no
    cmder.dev and opts.dep = no
    cmder.exclude and opts.exclude = cmder.exclude
    cmder.only and opts.include = cmder.only

    if cmder.dep and cmder.dev
        opts.devDep = ops.dep = yes
    opts

p = require('./updateSelf')(opts.mirror)
require('./npm-up') opts
.then ->
    p.log()
.catch (e) ->
    if e then console.error e.stack or e
    process.exit 1
