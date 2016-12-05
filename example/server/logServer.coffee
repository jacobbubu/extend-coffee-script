net = require 'net'
{ stringify } = require 'oneline-stringify'

module.exports =
    start: (port, host, cb)->
        if typeof host is 'function'
            cb = host
            host = '127.0.0.1'
        host ?= '127.0.0.1'
        net.createServer (socket) ->
            socket.name = socket.remoteAddress + ":" + socket.remotePort
            socket.on 'data', (data) ->
                try
                    message = JSON.parse(data)
                    process.stdout.write stringify(message) + '\n'
                catch
                    process.stdout.write data

        .listen port, host, cb
