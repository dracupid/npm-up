var Promise, Version, checkUpdate, fs, interval, npm, npmuprc, path, util, writeRC, _, _ref;

fs = require('nofs');

Promise = require('bluebird');

path = require('path');

util = require('./util');

_ = require('lodash');

npm = require('npm');

Version = require('./Version');

require('colors');

_ref = require('./npmuprc'), npmuprc = _ref.npmuprc, writeRC = _ref.writeRC;

interval = 12 * 3600 * 1000;

checkUpdate = function() {
  var promise, rc;
  rc = npmuprc;
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
