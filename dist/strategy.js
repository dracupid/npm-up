module.exports = {
  version: function(dep) {
    if (dep.declareVer === '*') {
      if (!dep.installedVer) {
        dep.needUpdate = true;
        dep.baseVer = dep.declareVer;
        dep.warnMsg = dep.packageName.cyan + " is not installed.";
      } else {
        dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0;
      }
    } else {
      if (!dep.installedVer) {
        dep.needUpdate = dep.declareVer.compareTo(dep.newVer) < 0;
        dep.baseVer = dep.declareVer;
        dep.warnMsg = dep.packageName.cyan + " is not installed.";
      } else {
        dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0;
        if (dep.installedVer.compareTo(dep.declareVer) < 0) {
          dep.warnMsg = ("Installed " + dep.packageName.cyan + " is outdated:") + (" Installed " + (dep.installedVer + '').red + " --> Declared " + (dep.declareVer + '').green);
        } else if (dep.installedVer.compareTo(dep.declareVer) > 0) {
          dep.warnMsg = ("You may want to update " + dep.packageName.cyan + "\'s version info:") + (" Installed " + (dep.installedVer + '').red + " --> Declared " + (dep.declareVer + '').green);
        }
      }
    }
    return dep;
  }
};
