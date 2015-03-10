{get} = require 'http'
{Promise} = require 'nofs'
{getRegistry} = require './util'

module.exports = (name, mirror = 'npm') ->
    new Promise (resolve, reject) ->
        get "http://#{getRegistry mirror}/-/package/#{name}/dist-tags", (res) ->
            res.setEncoding 'utf8'
            data = ''
            res.on 'data', (d) -> data += d
            res.on 'end', ->
                try
                    latest = JSON.parse(data).latest or ''
                    resolve latest
                catch e
                    reject e
        .on 'error', reject
