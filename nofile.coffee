# nofile-pre-require: coffee-script/register

kit = require 'nokit'
drives = kit.require 'drives'
$ = require('dracupid-no')(kit)

module.exports = (task, option)->
    option '-a, --all', 'build without cache'

    task 'build', "Build Project", (opts)->
        $.coffee useCache: not opts.all

    task 'help', ->
        kit.exec "coffee src/cli.coffee -h"
        .then ({stdout})->
            help = stdout.split /\n\s*\w*:/
            readme = kit._.template(kit.readFileSync('./docs/README.tpl', encoding: 'utf8'))({help})
            kit.writeFile 'README.md', readme

    task 'dev', 'run coffee source', ->
        kit.spawn 'coffee', ['src/cli.coffee']


    task 'default', ['build', 'help']
