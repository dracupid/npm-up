var Promise, Version, checkUpdate, fs, home, interval, npm, path, rcFile, readRc, util, writeRC, _;

fs = require('nofs');

Promise = require('bluebird');

path = require('path');

util = require('./util');

_ = require('lodash');

npm = require('npm');

Version = require('./Version');

require('colors');

home = process.platform === 'win32' ? process.env.USERPROFILE : process.env.HOME;

rcFile = path.join(home, '.npmuprc.json');

interval = 8 * 60 * 3600 * 1000;

readRc = function() {
  try {
    return require(rcFile);
  } catch (_error) {
    return {};
  }
};

writeRC = function(rc) {
  return fs.outputJSON(rcFile, rc, {
    space: 2
  })["catch"](function(e) {
    return console.log(e);
  });
};

checkUpdate = function() {
  var promise, rc;
  rc = readRc();
  promise = Promise.resolve();
  if (!rc.lastCheck || +new Date() - rc.lastCheck > interval) {
    promise = Promise.promisify(npm.load)({
      loglevel: 'error'
    }).then(function() {
      return Promise.promisify(npm.commands.v)(['npm-up', 'dist-tags.latest'], true);
    }).then(function(data) {
      rc.latest = _(data).keys().first();
      return rc.lastCheck = +new Date();
    }).then(function() {
      return writeRC(rc);
    });
  }
  return promise.then(function() {
    var installed, latest;
    installed = new Version(util.curVer);
    latest = new Version(rc.latest);
    if (installed.compareTo(latest) < 0) {
      return console.log(">>  A new version of npm-up is available !".yellow, " " + ('' + installed).green + " --> " + ('' + latest).red);
    }
  });
};

module.exports = checkUpdate;
