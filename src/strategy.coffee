"use strict"

semver = require 'semver'
chalk = require 'chalk'

verRe = /^[><=\s~^]*([\d\w.-\s]*)$/

upgradeMsg = (dep, plainDeclareVer) ->
    "#{chalk.yellow 'updgrade'} #{chalk.cyan dep.packageName}:" +
        " #{chalk.red dep.installedVer}(installed) --> #{chalk.green plainDeclareVer}(declared)"

bumpMsg = (dep, plainDeclareVer) ->
    "#{chalk.yellow 'bump'} #{chalk.cyan dep.packageName}:" +
        " #{chalk.red plainDeclareVer}(declared) --> #{chalk.green dep.installedVer}(installed)"

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

        else if m = declareVer.match verRe
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
                        dep.warnMsg = upgradeMsg dep, declareVer
                    else if semver.gt dep.installedVer, declareVer
                        dep.warnMsg = bumpMsg dep, declareVer
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
                dep.warnMsg = upgradeMsg dep, declareVer
            else if semver.gtr dep.installedVer, declareVer
                dep.warnMsg = bumpMsg dep, declareVer
        dep
