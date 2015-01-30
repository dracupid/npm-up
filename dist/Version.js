var Version, _;

_ = require('lodash');

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

module.exports = Version;
