cmder = require 'commander'

cmder
    .usage "[options]"
    .option '-w, --writeback', "Write updated version info back to package.json"
    .option '-i, --install', "Install the newest version of the packages that need to be updated."
    .option '-l, --lock', "Lock the version of the package in package.json, with no version prefix."
    .option '-a, --all', "alias for -wil."
    .option '-b, --backup [fileName]', "BackUp package.json before write back, default is package.bak.json."
    .option '-d, --dep', "Check dependencies only."
    .option '-D, --dev', "Check devDependencies only."
    .option '-s, --silent', "Do not log any infomation."
    .option '-e, --exclude <list>', "Don't check packages list, split by comma",
        (list)->
            list.split ','
    .option '-o, --only <list>', "Only check the packages list, split by comma",
        (list)->
            list.split ','

cmder.parse process.argv

init = ->
    opts = {}
    opts.writeBack = cmder.writeback
    opts.install = cmder.install
    opts.lock = cmder.lock
    opts.all = cmder.all
    cmder.dep and opts.devDep = no
    cmder.dev and opts.dep = no
    opts.silent = cmder.silent
    opts.backUp = cmder.backup
    cmder.exclude and opts.exclude = cmder.exclude
    cmder.only and opts.include = cmder.only

    if cmder.dep and cmder.dev
        opts.devDep = ops.dep = yes
    opts

opts = init()
require('./npm-up')(opts)