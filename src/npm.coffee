require 'colors'
which = require 'which'
fs = require 'nofs'

"use strict"

GLOBAL_NPM_BIN = fs.realpathSync which.sync 'npm'
GLOBAL_NPM_PATH = fs.path.join GLOBAL_NPM_BIN,
    if process.platform is "win32" then '../node_modules/npm' else '../..'

try
    npm = require GLOBAL_NPM_PATH
catch
    console.error "npm not found in #{GLOBAL_NPM_PATH} !".red
    process.exit 1

console.log "npm version: #{npm.version or 'Unknown'}".cyan

module.exports = npm
module.exports.GLOBAL_NPM_PATH = GLOBAL_NPM_PATH
module.exports.GLOBAL_NPM_BIN = GLOBAL_NPM_BIN
