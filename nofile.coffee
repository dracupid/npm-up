coffee = require 'coffee-script'
require 'nokit/global'

option '-a, --all', 'build without cache'

task 'build', "Build Project", (opts)->
    kit.warp 'libs/**', { isCache: not opts.all }
    .load drives.auto 'lint', '.coffee': config: 'coffeelint-strict.json'
    .load drives.auto 'compile'
    .run 'dist'

task 'default', ['build']
