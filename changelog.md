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
