var Promise, Version, cwdFilePath, logInfo, npm, path,
  __slice = [].slice;

path = require('path');

Version = require('./Version');

Promise = require('bluebird');

npm = require('npm');

cwdFilePath = function() {
  var names;
  names = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return path.join.apply(path, [process.cwd()].concat(names));
};

logInfo = function(str) {
  return console.log('\n>>  '.yellow + str.green);
};

module.exports = {
  cwdFilePath: cwdFilePath,
  readPackageFile: function(name, onError) {
    var filePath;
    filePath = name ? cwdFilePath('node_modules', name, 'package.json') : cwdFilePath('package.json');
    try {
      return require(filePath);
    } catch (_error) {
      onError && onError(filePath);
      return null;
    }
  },
  print: function(deps) {
    return deps.map(function(dep) {
      var padding;
      padding = (new Array(25 - dep.packageName.length)).join(' ');
      dep.needUpdate && console.log(("[" + dep.type + "]").green, dep.packageName.cyan, padding, dep.baseVer.toString().green, '->', dep.newVer.toString().red);
      return dep.warnMsg && console.log(" *  Warning: ".yellow + ("" + dep.warnMsg).white);
    });
  },
  parseVersion: function(ver) {
    ver = ver.trim();
    if (ver === '*' || ver === '') {
      return '*';
    } else if (/^[\D]?[\d\.]+\w*/.test(ver)) {
      return new Version(ver);
    } else {
      return null;
    }
  },
  logInfo: logInfo,
  install: function(packages) {
    if (packages.length === 0) {
      return Promise.resolve();
    }
    logInfo("Start to install...");
    console.log(packages.join(' ').cyan + " will be updated".green);
    return Promise.promisify(npm.commands.i)(packages).then(function() {
      return logInfo("Latest version of the packages has been installed!".green);
    });
  },
  curVer: (function() {
    return require('../package.json').version;
  })()
};
