var Promise, Version, formatPackages, fs, getNewVersion, globalPackage, modulesPath, npm, npmUp, npmUpGlobal, option, packageBakFile, packageFile, parseOpts, parsePackage, parseVersion, path, prepare, print, readPackageFile, _,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

require('colors');

npm = require('npm');

path = require('path');

Promise = require('bluebird');

_ = require('lodash');

fs = require('nofs');

packageFile = path.join(process.cwd(), 'package.json');

packageBakFile = path.join(process.cwd(), 'package.bak.json');

modulesPath = path.join(process.cwd(), 'node_modules');

option = {};

globalPackage = {};

parseOpts = function(opts) {
  option = _.defaults(opts, {
    include: "",
    exclude: [],
    writeBack: false,
    install: false,
    lock: false,
    all: false,
    devDep: true,
    dep: true,
    silent: false,
    backUp: false,
    lockAll: false
  });
  if (option.all) {
    _.assign(opts, {
      writeBack: true,
      install: true,
      lock: true
    });
  }
  option.exclude = _.compact(option.exclude);
  option.include && (option.include = _.compact(option.include));
  if (option.silent) {
    return console.log = function() {};
  }
};

readPackageFile = function(name, onError) {
  var filePath;
  filePath = name ? path.join(modulesPath, name, 'package.json') : packageFile;
  try {
    return require(filePath);
  } catch (_error) {
    onError && onError(filePath);
    return null;
  }
};

parseVersion = function(ver) {
  ver = ver.trim();
  if (ver === '*' || ver === '') {
    return '*';
  } else if (/^[\D]?[\d\.]+\w*/.test(ver)) {
    return new Version(ver);
  } else {
    return null;
  }
};

parsePackage = function(name, ver, type) {
  var declareVer, installedVer, pack;
  if (_.isArray(option.include) && !(__indexOf.call(option.include, name) >= 0)) {
    return null;
  }
  if (__indexOf.call(option.exclude, name) >= 0) {
    return null;
  }
  if (type === 'g') {
    declareVer = installedVer = new Version(ver);
  } else {
    declareVer = parseVersion(ver);
    if (!declareVer) {
      return null;
    }
    pack = readPackageFile(name);
    installedVer = pack ? new Version(pack.version) : null;
  }
  return {
    packageName: name,
    declareVer: declareVer,
    installedVer: installedVer,
    baseVer: installedVer,
    newVer: '',
    type: type,
    needUpdate: false,
    warnMsg: ''
  };
};

formatPackages = function(obj, type) {
  return _.map(obj, function(version, name) {
    var pack;
    return pack = parsePackage(name, version, type);
  });
};

prepare = function() {
  var deps;
  globalPackage = readPackageFile(null, function() {
    console.log("ERROR: package.json Not Found".red);
    return process.exit(1);
  });
  deps = [];
  if (option.dep) {
    deps = deps.concat(formatPackages(globalPackage.dependencies, 'S'));
  }
  if (option.devDep) {
    deps = deps.concat(formatPackages(globalPackage.devDependencies, 'D'));
  }
  return deps = _.compact(deps);
};

getNewVersion = function(dep) {
  return Promise.promisify(npm.commands.v)([dep.packageName, 'dist-tags.latest'], true).then(function(data) {
    dep.newVer = new Version(_(data).keys().first());
    if (dep.declareVer === '*') {
      if (!dep.installedVer) {
        dep.needUpdate = true;
        dep.baseVer = dep.declareVer;
        dep.warnMsg = "package " + dep.packageName + " is not installed.";
      } else {
        dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0;
      }
    } else {
      if (!dep.installedVer) {
        dep.needUpdate = dep.declareVer.compareTo(dep.newVer) < 0;
        dep.baseVer = dep.declareVer;
        dep.warnMsg = "package " + dep.packageName + " is not installed.";
      } else {
        dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0;
        if (dep.installedVer.compareTo(dep.declareVer) !== 0) {
          dep.warnMsg = "version info for " + dep.packageName + " can be updated. Installed " + dep.installedVer + ", declare " + dep.declareVer;
        }
      }
    }
    return dep;
  });
};

print = function(deps) {
  return _.map(deps, function(dep) {
    dep.needUpdate && console.log('>> ', dep.packageName.cyan, '\t', dep.baseVer.toString().green, '->', dep.newVer.toString().red);
    return dep.warnMsg && console.log(("WARN: " + dep.warnMsg).grey);
  });
};

npmUp = function(opts) {
  var deps;
  if (opts == null) {
    opts = {};
  }
  parseOpts(opts);
  deps = prepare();
  return Promise.promisify(npm.load, {
    loaded: false
  })().then(function() {
    console.log('Checking npm update...'.green);
    return Promise.all(_.map(deps, getNewVersion));
  }).then(function(newDeps) {
    deps = newDeps;
    print(deps);
    return console.log('Check npm update done!'.green);
  }).then(function() {
    var chain, toUpdate;
    toUpdate = _.map(_.filter(deps, function(dep) {
      return dep.needUpdate && dep.installedVer;
    }), function(dep) {
      return "" + dep.packageName + "@" + dep.newVer;
    });
    chain = new Promise(function(resolve) {
      return resolve();
    });
    if (option.writeBack) {
      chain.then(function() {
        var backFile;
        _.forEach(deps, function(dep) {
          var toWrite;
          toWrite = dep.newVer.verStr + dep.newVer.suffix;
          if (!option.lock) {
            toWrite = (dep.declareVer.prefix || '') + toWrite;
          }
          if (!option.lockAll && dep.declareVer === '*') {
            toWrite = '*';
          }
          if (dep.type === 'S') {
            globalPackage.dependencies[dep.packageName] = toWrite;
          }
          if (dep.type === 'D') {
            return globalPackage.devDependencies[dep.packageName] = toWrite;
          }
        });
        if (option.backUp) {
          if (_.isString(option.backUp)) {
            backFile = path.join(process.cwd(), option.backUp);
          } else {
            backFile = packageBakFile;
          }
          return fs.copyP(packageFile, backFile);
        }
      }).then(function() {
        return fs.writeFileP(packageFile, JSON.stringify(globalPackage, null, 2) + '\n');
      }).then(function() {
        return console.log("Package.json has been updated!".cyan);
      });
    }
    if (option.install) {
      if (toUpdate.length !== 0) {
        chain.then(function() {
          console.log(("" + toUpdate + " will be updated").cyan);
          return Promise.promisify(npm.commands.i)(toUpdate).then(function() {
            return console.log("Newest version of the packages has been installed!".green);
          });
        });
      } else {
        console.log("No package is updated.".green);
      }
    }
    return chain;
  });
};

Version = (function() {
  function Version(verStr) {
    var arr;
    arr = /^([\D])?([\d\.]+)(.*)/.exec(verStr || []);
    this.prefix = arr[1] || '';
    this.verStr = arr[2] || '';
    this.version = this.verStr.split('.' || '');
    this.suffix = arr[3] || '';
    this;
  }

  Version.prototype.toString = function() {
    return this.prefix + this.version.join('.') + this.suffix;
  };

  Version.prototype.compareTo = function(ver) {
    var arr, i, _i, _len;
    arr = _.zip(this.version, ver.version);
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      i = arr[_i];
      if (i[0] === i[1]) {
        continue;
      } else if (_.isUndefined(i[0])) {
        return -1;
      } else if (_.isUndefined(i[1])) {
        return 1;
      } else {
        return parseInt(i[0], 10) - parseInt(i[1], 10);
      }
    }
    return 0;
  };

  return Version;

})();

npmUpGlobal = function(opts) {
  parseOpts(opts);
  return Promise.promisify(npm.load, {
    loaded: false
  })().then(function() {
    console.log('Reading global packages...'.green);
    npm.config.set('global', true);
    return Promise.promisify(npm.commands.ls)(null, true);
  }).then(function(data) {
    var deps, globalDep;
    globalDep = data.dependencies || data[0].dependencies;
    console.log("Following packages are found: " + ((_.keys(globalDep)) + '').cyan);
    deps = _.map(globalDep, function(val, key) {
      return parsePackage(key, val.version, 'g');
    });
    console.log('Checking npm update...'.green);
    return Promise.all(_.map(_.compact(deps), getNewVersion));
  }).then(function(newDeps) {
    var chain, deps, toUpdate;
    deps = newDeps;
    print(deps);
    console.log('Check npm update done!'.green);
    toUpdate = _.map(_.filter(deps, function(dep) {
      return dep.needUpdate && dep.installedVer;
    }), function(dep) {
      return "" + dep.packageName + "@" + dep.newVer;
    });
    if (toUpdate.length === 0) {
      console.log("No package is updated.".green);
      return;
    }
    chain = new Promise(function(resolve) {
      return resolve();
    });
    if (option.install) {
      chain.then(function() {
        console.log(("" + toUpdate + " will be updated").cyan);
        npm.config.set('global', true);
        return Promise.promisify(npm.commands.i)(toUpdate).then(function() {
          return console.log("Newest version of the packages has been installed!".green);
        });
      });
    }
    return chain;
  });
};

module.exports = npmUp;

module.exports.npmUpGlobal = npmUpGlobal;
