npm = require 'global-npm'
chalk = require 'chalk'
console.log chalk.bold chalk.yellow("npm version:"),  chalk.magenta("#{npm.version or 'Unknown'}")

module.exports = npm
