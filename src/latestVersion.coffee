"use strict"

request = require 'kiss-request'
{Promise} = require 'nofs'
require.Promise = Promise
{getRegistry, debug} = require './util'

module.exports = (name, mirror = 'npm') ->
    link = getRegistry(mirror) + "/-/package/#{name}/dist-tags"
    debug link

    request link
    .then (data) ->
        debug data
        JSON.parse(data).latest or ''
    .catch (e) ->
        if e.code is 'TIMEOUT'
            Promise.reject new Error "Request to #{getRegistry(mirror)} timeout. Please use an alternative registry by -m <mirror>"
        else
            Promise.reject e
