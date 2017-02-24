"use strict"

request = require 'kiss-request'
{Promise} = require 'nofs'
{debug, isNPMRegistry, getRegistry} = require './util'
url = require 'url'

request.Promise = Promise

module.exports = (name, mirror) ->
    link = url.resolve mirror, "/-/package/#{encodeURIComponent(name)}/dist-tags"
    debug '[Request Link]', link

    request link
    .then (data) ->
        debug '[Version Data]', name + ":", data
        JSON.parse(data) or null
    .catch (e) ->
        if e.code is 'TIMEOUT'
            debug '[TIMEOUT]'
            Promise.reject new Error "Request to #{mirror} timeout. Try to use an alternative registry by -m <mirror>"
        else if e.code is 'UNWANTED_STATUS_CODE'
            if e.statusCode == 404 and not isNPMRegistry(mirror)
                debug '[FALLBACK NPM]'
                module.exports(name, getRegistry('npm'))
            else
                debug '[UNWANTED_STATUS_CODE]', e, '; link: ', link
                Promise.resolve null
        else
            Promise.reject e
