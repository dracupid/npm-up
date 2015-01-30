coffee = require 'coffee-script'

noCoffee = (opt) -> (file) ->
    file.set coffee.compile file.contents + '', opt
    file.dest = file.dest.replace '.coffee', '.js'
    file

task 'build', "Build Project", ->
    kit.warp 'libs/**'
    .pipe noCoffee bare: true
    .to 'dist'
    .then ->
        kit.log "build done!"

