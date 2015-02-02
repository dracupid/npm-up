var Version, checkVer, formatPackages, fs, globalPackage, modulesPath, npm, npmUp, npmUpGlobal, option, packageBakFile, packageFile, parseOpts, parsePackage, path, prepare, util,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

require('colors');

npm = require('npm');

path = require('path');

global.Promise = require('bluebird');

global._ = require('lodash');

fs = require('nofs');

Version = require('./Version');

util = require('./util');

checkVer = require('./checkVersion');

packageFile = util.cwdFilePath('package.json');

packageBakFile = util.cwdFilePath('package.bak.json');

modulesPath = util.cwdFilePath('node_modules');

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
    lockAll: false,
    cache: true
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

parsePackage = function(name, ver, type) {
  var declareVer, installedVer, pack;
  if (Array.isArray(option.include) && !(__indexOf.call(option.include, name) >= 0)) {
    return null;
  }
  if (__indexOf.call(option.exclude, name) >= 0) {
    return null;
  }
  if (type === 'g') {
    declareVer = installedVer = new Version(ver);
  } else {
    declareVer = util.parseVersion(ver);
    if (!declareVer) {
      return null;
    }
    pack = util.readPackageFile(name);
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
  globalPackage = util.readPackageFile(null, function() {
    console.error("ERROR: package.json Not Found".red);
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

npmUp = function() {
  var deps;
  deps = prepare();
  return Promise.promisify(npm.load)({
    loglevel: 'error'
  }).then(function() {
    util.logInfo('Checking package\'s version...');
    return checkVer(deps, option.cache);
  }).then(function(newDeps) {
    var chain, toUpdate;
    deps = newDeps;
    util.print(deps);
    toUpdate = _.map(_.filter(deps, function(dep) {
      return dep.needUpdate && dep.installedVer;
    }), function(dep) {
      return dep.packageName + "@" + dep.newVer;
    });
    chain = Promise.resolve();
    if (toUpdate.length === 0) {
      util.logInfo("Everything is new!");
    }
    if (option.writeBack) {
      chain = chain.then(function() {
        var backFile;
        deps.forEach(function(dep) {
          var toWrite;
          toWrite = dep.newVer.verStr + dep.newVer.suffix;
          if (!option.lock) {
            toWrite = (dep.declareVer.prefix || '') + toWrite;
          }
          if (!option.lockAll && dep.declareVer === '*') {
            toWrite = '*';
          }
          switch (dep.type) {
            case 'S':
              return globalPackage.dependencies[dep.packageName] = toWrite;
            case 'D':
              return globalPackage.devDependencies[dep.packageName] = toWrite;
          }
        });
        if (option.backUp) {
          backFile = _.isString(option.backUp) ? util.cwdFilePath(option.backUp) : packageBakFile;
          return fs.copy(packageFile, backFile);
        }
      }).then(function() {
        return fs.outputJSON(packageFile, globalPackage, {
          space: 2
        });
      }).then(function() {
        return util.logInfo("package.json has been updated!");
      });
    }
    if (option.install) {
      chain = chain.then(function() {
        return util.install(toUpdate);
      });
    }
    return chain;
  });
};

npmUpGlobal = function() {
  return Promise.promisify(npm.load)({
    loglevel: 'error',
    global: true
  }).then(function() {
    util.logInfo('Reading global installed packages...');
    return Promise.promisify(npm.commands.ls)(null, true);
  }).then(function(data) {
    var deps, globalDep;
    globalDep = data.dependencies || data[0].dependencies;
    console.log(((_.keys(globalDep)).join(' ')).cyan);
    deps = _.map(globalDep, function(val, key) {
      return parsePackage(key, val.version, 'g');
    });
    util.logInfo('Checking package\'s version...');
    return checkVer(_.compact(deps), option.cache);
  }).then(function(newDeps) {
    var deps, toUpdate;
    deps = newDeps;
    util.print(deps);
    toUpdate = _.map(_.filter(deps, function(dep) {
      return dep.needUpdate && dep.installedVer;
    }), function(dep) {
      return dep.packageName + "@" + dep.newVer;
    });
    if (toUpdate.length === 0) {
      util.logInfo("Everything is new!");
      return Promise.resolve();
    }
    if (option.install) {
      return util.install(toUpdate);
    }
  });
};

module.exports = function(opt, type) {
  var promise;
  parseOpts(opt);
  promise = type === 'global' ? npmUpGlobal() : npmUp();
  return promise["catch"](function(e) {
    throw e;
    return process.exit(1);
  });
};
