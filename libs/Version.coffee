_ = require 'lodash'

class Version
    constructor: (verStr)->
        arr = /^([\D])?([\d\.]+)(.*)/.exec verStr or []
        @prefix = arr[1] or ''
        @verStr = arr[2] or ''
        @version = @verStr.split '.' or ''
        @suffix = arr[3] or ''
        @

    toString: ()->
        @prefix + @version.join('.') + @suffix

    compareTo: (ver)->
        arr = _.zip @version, ver.version
        for i in arr
            if i[0] is i[1] then continue
            else if _.isUndefined i[0] then return -1
            else if _.isUndefined i[1] then return 1
            else return parseInt(i[0], 10) - parseInt(i[1], 10)
        return 0

module.exports = Version
