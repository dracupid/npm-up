which = require 'which'
fs = require 'nofs'
require 'colors'

GLOBAL_NPM_PATH = fs.path.join fs.realpathSync(which.sync 'npm'), '../..'

try
    npm = require GLOBAL_NPM_PATH
catch
    console.err "npm not found!".red
    process.exit 1

console.log "\nnpm version: #{npm.version or 'Unknown'}".cyan

module.exports = npm
