{get} = require 'http'
{Promise} = require 'nofs'

host =
    npm: 'registry.npmjs.org'
    taobao: 'registry.npm.taobao.org'
    cnpmjs: 'r.cnpmjs.org'

module.exports = (name, mirror = 'npm') ->
    new Promise (resolve, reject) ->
        get "http://#{host[mirror] or mirror}/-/package/#{name}/dist-tags", (res) ->
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
