coffee = require 'coffee-script'

noCoffee = (opt) -> (file) ->
    file.dest = file.dest.replace '.coffee', '.js'
    file.set coffee.compile file.contents + '', opt

task 'build', "Build Project", ->
    kit.warp 'libs/**'
    .pipe noCoffee bare: true
    .to 'dist'
    .then ->
        kit.log "build done!"

