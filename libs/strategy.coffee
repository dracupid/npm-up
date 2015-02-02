module.exports =
    version: (dep)->
        if dep.declareVer is '*'
            # '*' -> 'not installed'
            if not dep.installedVer
                dep.needUpdate = yes
                dep.baseVer =  dep.declareVer
                dep.warnMsg = "#{dep.packageName.cyan} is not installed."
            # '*' -> 'x.x.x'
            else
                dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0
        else
            # 'X.X.X' -> 'not installed'
            if not dep.installedVer
                dep.needUpdate = dep.declareVer.compareTo(dep.newVer) < 0
                dep.baseVer =  dep.declareVer
                dep.warnMsg = "#{dep.packageName.cyan} is not installed."

            # 'X.X.X' -> 'X.X.X'
            else
                dep.needUpdate = dep.installedVer.compareTo(dep.newVer) < 0
                if dep.installedVer.compareTo(dep.declareVer) < 0
                    dep.warnMsg = "Installed #{dep.packageName.cyan} is outdated:" +
                        " Installed #{(dep.installedVer + '').red} --> Declared #{(dep.declareVer + '').green}"
                else if dep.installedVer.compareTo(dep.declareVer) > 0
                    dep.warnMsg = "You may want to update #{dep.packageName.cyan}\'s version info:" +
                        " Installed #{(dep.installedVer + '').red} --> Declared #{(dep.declareVer + '').green}"
        dep
