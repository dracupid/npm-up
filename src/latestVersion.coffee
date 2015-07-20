"use strict"

request = require 'kiss-request'
{Promise} = require 'nofs'
require.Promise = Promise
{getRegistry, debug} = require './util'
url = require 'url'

module.exports = (name, mirror = 'npm') ->
    link = url.resolve mirror, "/-/package/#{name}/dist-tags"
    debug link

    request link
    .then (data) ->
        debug data
        JSON.parse(data).latest or ''
    .catch (e) ->
        if e.code is 'TIMEOUT'
            Promise.reject new Error "Request to #{mirror} timeout. Please use an alternative registry by -m <mirror>"
        else if e.code is 'UNWANTED_STATUS_CODE'
            Promise.resolve ''
        else
            Promise.reject e
