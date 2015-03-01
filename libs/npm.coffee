which = require 'which'
fs = require 'nofs'
require 'colors'

GLOBAL_NPM_PATH = fs.path.join fs.realpathSync(which.sync 'npm'), '../..'

try
    npm = require GLOBAL_NPM_PATH
catch
    console.error "npm not found in #{GLOBAL_NPM_PATH}!".red
    process.exit 1

console.log "npm version: #{npm.version or 'Unknown'}".cyan

module.exports = npm
