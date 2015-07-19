npm = require 'global-npm'
require 'colors'
console.log "npm version:".yellow.bold,  "#{npm.version or 'Unknown'}".magenta.bold

module.exports = npm
