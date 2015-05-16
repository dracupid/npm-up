npm = require 'global-npm'
require 'colors'
console.log "npm version: #{npm.version or 'Unknown'}".cyan

module.exports = npm
