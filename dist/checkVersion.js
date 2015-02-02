var Version, cache, npm, strategy;

cache = require('./cache');

Version = require('./Version');

strategy = require('./strategy');

npm = require('npm');

module.exports = function(deps, useCache) {
  var npmView;
  npmView = Promise.promisify(npm.commands.v);
  return Promise.all(deps.map(function(dep) {
    var name, promise, ver;
    name = dep.packageName;
    ver = cache.get(name);
    if (ver && useCache) {
      promise = Promise.resolve(ver);
    } else {
      promise = npmView([name, 'dist-tags.latest'], true).then(function(data) {
        ver = _(data).keys().first();
        cache.set(name, ver);
        return ver;
      });
    }
    return promise.then(function(ver) {
      dep.newVer = new Version(ver);
      return strategy.version(dep);
    });
  })).then(function(deps) {
    cache.record();
    return deps;
  });
};
