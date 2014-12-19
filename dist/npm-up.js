var Promise, deps, format, getNewVersion, kit, npm, pack, print, _;

npm = require('npm');

kit = require('nokit');

_ = kit._, Promise = kit.Promise;

try {
  pack = require(kit.path.join(process.cwd(), './package.json'));
} catch (_error) {
  kit.err("[404] package.json Not Found".red);
}

format = function(obj, type) {
  return _.map(obj, function(v, k) {
    return {
      packageName: k,
      curVer: /\D?([\d\.]*)\w*/.exec(v)[1],
      newVer: '',
      type: type,
      needUpdate: false
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
    if (dep.newVer !== dep.curVer) {
      return dep.needUpdate = true;
    }
  });
};

print = function() {
  return _.map(deps, function(dep) {
    return dep.needUpdate && console.log('>> ', dep.packageName.yellow, ': ', dep.curVer.green, '->', dep.newVer.red);
  });
};

module.exports = Promise.promisify(npm.load, {
  loaded: false
})().then(function() {
  return console.log('Checking npm update...'.green);
}).then(function() {
  return Promise.all(_.map(deps, getNewVersion));
}).done(function() {
  print();
  return console.log('Check update done.'.green);
});
