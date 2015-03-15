"use strict"

get =
    'http:': require('http').get
    'https:': require('https').get
url = require 'url'
{Promise} = require 'nofs'
{getRegistry, debug} = require './util'

module.exports = (name, mirror = 'npm') ->
    link = getRegistry(mirror) + "/-/package/#{name}/dist-tags"
    debug link
    getUrl = get[url.parse(link).protocol] or get['http:']

    new Promise (resolve, reject) ->
        getUrl link, (res) ->
            res.setEncoding 'utf8'
            data = ''
            res.on 'data', (d) -> data += d
            res.on 'end', ->
                debug data
                try
                    resolve JSON.parse(data).latest or ''
                catch e
                    reject e
        .on 'error', reject
