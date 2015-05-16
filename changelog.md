v1.8.0
======
- upd: nofs & which
- add: node v0.8 support
- use [yaku](https://github.com/ysmood/yaku) to replace bluebird

v1.7.0
=======
- upd: dep
- fix: bug for private package
- question: Don't install npm by npm-up. A broken error may occur and I wonder why.

v1.6.4
=======
- upd: dep
- typo
- use strict

v1.6.3
======
- fix: null version

v1.6.2
======
- fix: cache clean issue
- opt: mirror supports https now.

v1.6.1
======
- opt: If a package is not installed, and declared version is *, nothing will happen.
- fix: If mirror is not set, don't overwrite it by `http://registry.npmjs.org/`.

v1.6.0
======
- **change**: cli arg name
    - `--ALL`       --> `--All`
    - `--writeback` --> `--writeback`
    - `-v, --ver`   --> `-V, --version` (provided by commander)
- **Use restful API to check latest version.**
- opt: performance
- No warning when a package is not installed.
- Support mirror registry server

v1.5.5
=======
- fix: [#2](https://github.com/dracupid/npm-up/issues/2), caused by misusing of `_.isEmpty()` when arg is boolean.
- opt: cli symbols in windows

v1.5.4
=======
- fix: `npm-up clean`
- opt: clean cache automatically, rename cache file
- opt: `exclude` and `include` cli arg use space or comma to split
- upd: lodash, nofs

v1.5.3
========
- fix: invalid writeback arg

v1.5.2
=========
- add: -c, --cwd option
- add: --no-warning option

v1.5.1
=======
- fix: error handler

v1.5.0
========
- **Use global npm**

v1.4.7
=========
- fix: error handler.
- minor optimize and fix

v1.4.6
=========
- fix: `npm-up -A` error strategy.

v1.4.5
==========
- fix: exit when permission denied

v1.4.4
=========
- ADD: Detect Permission Denied error when install global packages to avoid incomplete Installations.

v1.4.3
========
- ADD: set npm loglevel by `-L info`.

v1.4.2
=========
- **ADD: Check all projects in sub directories** `npm-up -A`

v1.4.1
===========
- upd: dep

v1.4.0
========
- **BIG CHANGE**: use [semver](https://github.com/npm/node-semver) to parse and compare version.
- ADD: support all kinds of semantic version.
- **COMMAND CHANGE**: `npm-up cache` to `npm-up dump`.
- opt: print
- bug fix
- update npm to v2.6.0

v1.3.2
=========
- minor fix
- upd: dep

v1.3.1
=========
- minor fix
- update nofs

v1.3.0
==========
- opt: update checking interval changed to 12 hours.
- NEW feature: version cache (expires in 10 minutes)
- NEW: cli flag --no-cache
- NEW: cli command: cache & clean
- fix: too long package name may cause padding overflow

v1.2.4
===========
- fix typo

v1.2.3
==========
- update bluebird
- fix update interval

v1.2.2
==========
- update nofs & nokit
- fix a promise return value bug
- overwrite outdated version info

v1.2.1
============
- check latest version of npm-up itself
- fix minor bugs

v1.2.0
=============
- opt: usage of npm config
- use `nokit` to build
- upd: dep
- Modularize and clean code
- More pretty print.

v1.1.3
==============
- Just update dependency

v1.1.2
=============
- fix: add suffix when write back

v1.1.1
===============
- fix: UNMET DEPENDENCY and version error

v1.0.9
===============
- fix: checking global installed packages correctly

v1.0.8
===============
- use nofs directly instead of nokit
- fix: lock-all don't lock

v1.0.7
================
- use `--lock-all` to lock a `*` version
- fix typo

v1.0.5 - v1.0.6
=================
- fix stupid mistakes

v1.0.4
=================
- Fix: When no package is installed, `package.json` is not able to be overwritten when flag `whiteback` is set.

v1.0.3
==================
- Support checking and update global packages.

v1.0.2
===================
- If the version is `*` in `package.json`, it will never be overwritten, even the flag `lock` is set.

v1.0.1
===================
- Add `-v` flag to display the current version.
- Add a newline at the end of `package.json` after writing back.


> I am sorry that the version is bumped from 0.1.0 to 1.0.1 by mistake.

v0.1.0
===================
- npm-up is much more powerful.
- Support command line arguments.
