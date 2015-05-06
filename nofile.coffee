kit = require 'nokit'
drives = kit.require 'drives'
$ = require('dracupid-no')(kit)

module.exports = (task, option)->
    option '-a, --all', 'build without cache'

    task 'build', "Build Project", (opts)->
        $.coffee()

    task 'help', ->
        kit.exec "coffee src/cli.coffee -h"
        .then ({stdout})->
            help = stdout.split /\n\s*\w*:/
            readme = kit._.template('' + kit.readFileSync('./asserts/README.tpl'))(help: help)
            kit.writeFile 'README.md', readme

    task 'default', ['build', 'help']
