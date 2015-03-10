{get} = require 'https'
{Promise} = require 'nofs'

module.exports = (name) ->
    new Promise (resolve, reject) ->
        get 'https://registry.npmjs.org/-/package/' + name + '/dist-tags', (res) ->
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
