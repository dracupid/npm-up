"use strict"

semver = require 'semver'

module.exports =
    version: (dep) ->
        declareVer = dep.declareVer
        if declareVer is '*'
            # '*' -> 'not installed'
            if not dep.installedVer
                dep.needUpdate = false
                dep.baseVer = declareVer
                # dep.warnMsg = "#{dep.packageName.cyan} may not be installed."
            # '*' -> 'x.x.x'
            else
                dep.needUpdate = semver.lt dep.installedVer, dep.newVer
            return dep

        else if m = declareVer.match /^[><=\s~^]*([\d\w.-\s]*)$/
            declareVer = m[1]
            if semver.valid declareVer
                # 'X.X.X' -> 'not installed'
                if not dep.installedVer
                    dep.needUpdate = semver.lt declareVer, dep.newVer
                    dep.baseVer =  declareVer
                    # dep.warnMsg = "#{dep.packageName.cyan} may not be installed."

                # 'X.X.X' -> 'X.X.X'
                else
                    dep.needUpdate = semver.lt dep.installedVer, dep.newVer
                    if semver.lt dep.installedVer, declareVer
                        dep.warnMsg = "Installed #{dep.packageName.cyan} is outdated:" +
                            " Installed #{dep.installedVer.red} --> Declared #{declareVer.green}"
                    else if semver.gt dep.installedVer, declareVer
                        dep.warnMsg = "Declared #{dep.packageName.cyan} is outdated:" +
                            " Declared #{declareVer.green} --> Installed #{dep.installedVer.red}"
                return dep

        # Other Range -> 'not installed'
        if not dep.installedVer
            dep.needUpdate = semver.gtr dep.newVer, declareVer
            dep.baseVer =  declareVer
            # dep.warnMsg = "#{dep.packageName.cyan} may not be installed."

        # Other Range -> 'X.X.X'
        else
            dep.needUpdate = semver.lt dep.installedVer, dep.newVer
            if semver.ltr dep.installedVer, declareVer
                dep.warnMsg = "Installed #{dep.packageName.cyan} is outdated:" +
                    " Installed #{dep.installedVer.red} --> Declared #{declareVer.green}"
            else if semver.gtr dep.installedVer, declareVer
                dep.warnMsg = "Declared #{dep.packageName.cyan} is outdated:" +
                    " Declared #{declareVer.green} --> Installed #{dep.installedVer.red}"
        dep
