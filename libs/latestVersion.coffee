{get} = require 'http'
{Promise} = require 'nofs'
{getRegistry, debug} = require './util'

module.exports = (name, mirror = 'npm') ->
    new Promise (resolve, reject) ->
        url = "http://#{getRegistry mirror}/-/package/#{name}/dist-tags"
        debug url
        get url, (res) ->
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
