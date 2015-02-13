npm-up
======

A lightweight tool to check the latest version of dependent npm packages for a project and do whatever you want.

[![NPM version](https://badge.fury.io/js/npm-up.svg)](http://badge.fury.io/js/npm-up)
[![Deps Up to Date](https://david-dm.org/dracupid/npm-up.svg?style=flat)](https://david-dm.org/dracupid/npm-up)
[![Build Status](https://travis-ci.org/dracupid/npm-up.svg)](https://travis-ci.org/dracupid/npm-up)
[![Build status](https://ci.appveyor.com/api/projects/status/github/dracupid/npm-up?svg=true)](https://ci.appveyor.com/project/dracupid/npm-up)

## Installation
```bash
npm i npm-up -g
```

## Usage
1. run `npm-up [options]` in a project directory with a `package.json` file.For example: `npm-up -ab`
If no options are set, it will only check the latest version and do nothing but display.

2. run `npm-up -g` to check globally install npm packages.

####commands:
```
    clean                   clean cache
    cache                   dump cache
```

####Options:
```
    -h, --help               output usage information
    -v, --ver                Display the current version of npm-up
    -g, --global             Check global packages
    -w, --writeback          Write updated version info back to package.json
    -i, --install            Install the newest version of the packages that need to be updated.
    -l, --lock               Lock the version of the package in package.json, with no version prefix.
    --lock-all               Lock, even * version
    -a, --all                alias for -wil.
    --no-cache               do not use version cache.
    -b, --backup [fileName]  BackUp package.json before write back, default is package.bak.json.
    -d, --dep                Check dependencies only.
    -D, --dev                Check devDependencies only.
    -s, --silent             Do not log any infomation.
    -e, --exclude <list>     Excluded packages list, split by comma
    -o, --only <list>        Only check the packages list, split by comma
```

## Version Pattern
Only support number version with prefix and suffix, or `*`. Eg:
```
*
^1.5.4
~2.3
0.9.7
>=0.9.8
0.5.0-alpha1
'' //regard as *
```
Version strings with **ranges** are not supported by now.
```
>= 1.0.0    // Version Range
1.2 - 2.3.4 // Hyphen Ranges
1.x         // X-Ranges
```

- However, the semantic meaning of the prefix and suffix is **ignored**, because **I just want the latest version**.
- If the version declared in the `package.json` is not recognizable, the corresponding package will be **excluded**.
- More info: https://docs.npmjs.com/misc/semver

## Rules
1. Take 3 versions into consideration for one package:
    - Version declared in `package.json`
    - Version of the package installed
    - The latest version of the package
2. If a package is not installed, only `package.json` will be updated, and the package itself won't be installed.
3. If the version is `*` in `package.json`, it will not be overwritten, even when the flag `lock` is set. If you really want to change a * version, use `--lock-all`.
4. The preifx of the version will be preserved when written back, unless flag `lock` is set.
5. If the version installed is not the same as the version declared in `package.json`, there comes a warning.
6. Installed version is preferred.

## How to build
`no build`

> You need to install [`nokit`](https://github.com/ysmood/nokit) globally first
