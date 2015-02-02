var expire, get, npmuprc, set, writeRC, _ref;

_ref = require('./npmuprc'), npmuprc = _ref.npmuprc, writeRC = _ref.writeRC;

if (npmuprc.verCache == null) {
  npmuprc.verCache = {};
}

expire = 10 * 60 * 1000;

get = function(name) {
  var info, interval, now;
  info = npmuprc.verCache[name];
  now = +new Date();
  if (info) {
    interval = info.expire || expire;
    if (now - info.timestamp < interval) {
      return info.version;
    } else {
      delete npmuprc.verCache[name];
      return '';
    }
  } else {
    return '';
  }
};

set = function(name, ver) {
  return npmuprc.verCache[name] = {
    version: ver,
    timestamp: +new Date()
  };
};

module.exports = {
  get: get,
  set: set,
  record: writeRC
};
