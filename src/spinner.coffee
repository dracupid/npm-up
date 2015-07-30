'use strict'

readline = require 'readline'
chalk = require 'chalk'

Spinner = require('cli-spinner').Spinner

spinner = new Spinner chalk.green.bold '>> Fetching... %s'

module.exports =
    start: -> spinner.start()
    stop: ->
        spinner.stop()
        readline.clearLine process.stdout, 0
        readline.cursorTo process.stdout, 0
