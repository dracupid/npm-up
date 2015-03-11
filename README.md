npm-up
======

Check the latest version of dependencies on [npm](https://www.npmjs.com) gracefully, and do whatever you want.

[![NPM version](https://badge.fury.io/js/npm-up.svg)](https://www.npmjs.com/package/npm-up)
[![Downloads](http://img.shields.io/npm/dm/npm-up.svg)](https://www.npmjs.com/package/npm-up)
[![Deps](https://david-dm.org/dracupid/npm-up.svg?style=flat)](https://david-dm.org/dracupid/npm-up)
[![Build Status](https://travis-ci.org/dracupid/npm-up.svg)](https://travis-ci.org/dracupid/npm-up)
[![Build status](https://ci.appveyor.com/api/projects/status/github/dracupid/npm-up?svg=true)](https://ci.appveyor.com/project/dracupid/npm-up)

## Installation
```bash
npm i npm-up -g
```

## Usage
1. Run `npm-up [options]` in a project directory with a `package.json` file. For example: `npm-up -iw`. <br/>
If no options are configured, it will only check the latest version and do nothing but display.

2. Run `npm-up -g` to check globally install npm packages.

3. Run `npm-up -A` to check all projects in sub directories.

#### commands:

```
clean   clean cache
dump    dump cache
```

#### Options:
```
-h, --help                          output usage information
-V, --version                       output the version number
-g, --global                        Check global packages
-A, --All                           Check all projects in sub directories, depth is 1
-w, --writeBack                     Write updated version back to package.json
-i, --install                       Install the latest version of the packages
-l, --lock                          Use specific versions in package.json, with no ranges. (except *)
--lock-all                          Lock, even for * version
-a, --all                           Shortcut for -wil
-m, --mirror <mirror host or name>  Use a mirror registry host
--no-cache                          Disable version cache temporarily
--no-warning                        Disable warning
-b, --backup [fileName]             Backup package.json before writing back, default name is package.bak.json
-d, --dep                           Check dependencies only
-D, --dev                           Check devDependencies only
-s, --silent                        Do not print any log
-c, --cwd <cwd>                     Set current working directory
-L, --logLevel <level>              Set loglevel for npm, default is error
-e, --exclude <list>                Excluded packages list, split by comma or space
-o, --only <list>                   Included packages list, split by comma or space
```


## Use mirror registry

First of all, You can use something like
```
npm config set registry http://registry.npm.taobao.org
```
to set a npm registry globally to speed up npm's requests, such as version searching and package downloading, especially for Chinese users.<br/>

However, it may cause some trouble (you can't publish unless use `-reg` every time, because a mirror is usually read-only).

In npm-up
- You can use a built-in host with name:
```bash
npm-up -m taobao  # also suport cnpmjs, npm(official), skimdb
```
- or give a specific hostname (only allow `http` now, it is faster.)
```bash
npm-up -m registry.npm.taobao.org
```

> **For Chinese users, use `-m taobao` to fly up!**

## Version Patterns
Fully support semantic versions. Eg:
```
*
^1.5.4
~2.3
0.9.7
0.5.0-alpha1
'' //regard as *
```

Notice that a **ranges** version may be overridden by Caret Ranges(^) when written back, and will be updated only when the latest version is greater than all the versions possible in the range.
```
>= 1.0.0 <= 1.5.4   // Version Range
1.2 - 2.3.4         // Hyphen Ranges
1.x                 // X-Ranges
```
- However, the semantic meaning of the ranges may somehow be **ignored**, because **I just want the latest version**.
- If the version declared in the `package.json` is not recognizable, the corresponding package will be **excluded**.
- More info: https://docs.npmjs.com/misc/semver

## Rules
0. Take 3 versions into consideration for one package:
    - Version declared in `package.json`.
    - Version of the package installed.
    - The latest version of the package.

0. If a package is not installed, only `package.json` will be updated, and the package itself won't be installed.

0. If the version declared is `*`, it will not be overwritten, even when the flag `--lock` is set. If you really want to change it, use `--lock-all` flag.

0. The prefix `^ ~` of the version will be preserved when written back, unless flag `--lock` is set.

0. If an installed package's version is different from the version declared, there comes a warning.

0. Installed version is preferred.

## Roadmap
1. Use a config file to provide some persist options, like npmrc, we can have a real npmuprc.

## License
MIT
