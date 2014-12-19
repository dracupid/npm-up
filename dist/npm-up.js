var Promise, deps, format, getNewVersion, kit, npm, pack, print, versionFilter, _;

npm = require('npm');

kit = require('nokit');

_ = kit._, Promise = kit.Promise;

try {
  pack = require(kit.path.join(process.cwd(), './package.json'));
} catch (_error) {
  kit.err("[404] package.json Not Found".red);
  process.exit(0);
}

versionFilter = function(ver) {
  if (ver === '*' || ver === '') {
    return '*';
  } else {
    return /\D?([\d\.\*]*)\w*/.exec(ver)[1];
  }
};

format = function(obj, type) {
  return _.map(obj, function(v, k) {
    var curVer, installedVer, path;
    path = kit.path.join(process.cwd(), "./node_modules/" + k + "/package.json");
    curVer = versionFilter(v);
    try {
      installedVer = require(path).version;
    } catch (_error) {
      installedVer = curVer === '*' ? 'not installed' : curVer;
    }
    curVer === '*' && (curVer = installedVer);
    return {
      packageName: k,
      curVer: curVer,
      installedVer: installedVer,
      newVer: '',
      type: type,
      needUpdateJSON: false,
      needUpdate: false,
      packagePath: path
    };
  });
};

deps = format(pack.dependencies, 'S').concat(format(pack.devDependencies, 'D'));

getNewVersion = function(dep) {
  return Promise.promisify(npm.commands.v)([dep.packageName, 'dist-tags.latest'], true).then(function(data) {
    dep.newVer = _(data).keys().first();
    if (dep.type === 'S') {
      pack.dependencies[dep.packageName] = dep.newVer;
    } else {
      pack.devDependencies[dep.packageName] = dep.newVer;
    }
    if (dep.installedVer !== dep.curVer) {
      dep.needUpdateJSON = true;
    }
    if (dep.newVer !== dep.installedVer) {
      return dep.needUpdate = true;
    }
  });
};

print = function() {
  return _.map(deps, function(dep) {
    dep.needUpdate && console.log('>> ', dep.packageName.yellow, ': ', dep.installedVer.green, '->', dep.newVer.red);
    if (!dep.needUpdate && dep.needUpdateJSON) {
      return console.log(">> Your package.json can be updated: ", dep.packageName.yellow, ': ', dep.curVer.green, '->', dep.installedVer.red);
    }
  });
};

Promise.promisify(npm.load, {
  loaded: false
})().then(function() {
  return console.log('Checking npm update...'.green);
}).then(function() {
  return Promise.all(_.map(deps, getNewVersion));
}).done(function() {
  print();
  return console.log('Check update done.'.green);
});
