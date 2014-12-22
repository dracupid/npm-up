var cmder, init, opts, pack;

cmder = require('commander');

cmder.usage("[options]").option('-v, --ver', "Display the current version of npm-up").option('-w, --writeback', "Write updated version info back to package.json").option('-i, --install', "Install the newest version of the packages that need to be updated.").option('-l, --lock', "Lock the version of the package in package.json, with no version prefix.").option('-a, --all', "alias for -wil.").option('-b, --backup [fileName]', "BackUp package.json before write back, default is package.bak.json.").option('-d, --dep', "Check dependencies only.").option('-D, --dev', "Check devDependencies only.").option('-s, --silent', "Do not log any infomation.").option('-e, --exclude <list>', "Don't check packages list, split by comma", function(list) {
  return list.split(',');
}).option('-o, --only <list>', "Only check the packages list, split by comma", function(list) {
  return list.split(',');
});

cmder.parse(process.argv);

init = function() {
  var opts;
  opts = {};
  opts.writeBack = cmder.writeback;
  opts.install = cmder.install;
  opts.lock = cmder.lock;
  opts.all = cmder.all;
  cmder.dep && (opts.devDep = false);
  cmder.dev && (opts.dep = false);
  opts.silent = cmder.silent;
  opts.backUp = cmder.backup;
  cmder.exclude && (opts.exclude = cmder.exclude);
  cmder.only && (opts.include = cmder.only);
  if (cmder.dep && cmder.dev) {
    opts.devDep = ops.dep = true;
  }
  return opts;
};

if (cmder.ver) {
  pack = require('../package.json');
  console.log(pack.version);
} else {
  opts = init();
  require('./npm-up')(opts);
}
