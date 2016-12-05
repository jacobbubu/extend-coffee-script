util = require('util')
assert = require('assert')
now = require('date-now')
slice = Array::slice
times = {}

viaBridge = app.name.indexOf('Illustrator') > -1
if !viaBridge
    socket = new Socket()
    socket.encoding = 'utf-8'

innerLog = (level, args...) ->
    serialize = (value) -> JSON.stringify value

    if !viaBridge
        if !socket.connected
            if socket.open CONFIG.logServer.host + ':' + CONFIG.logServer.port
                socket.writeln JSON.stringify { level, args }
        else
            socket.writeln serialize { level, args }
    else
        bt = new BridgeTalk()
        bt.target = 'bridge'
        bt.body = """
            var socket = new Socket();
            socket.encoding = 'utf-8';
            if (socket.open('#{CONFIG.logServer.host}:#{CONFIG.logServer.port}')) {
                socket.writeln('#{ serialize { level, args } }');
            }
            socket.close();
        """
        bt.send()

    $.writeln serialize { level, args }

log = innerLog.bind console, 'log'

info = innerLog.bind console, 'info'

warn = innerLog.bind console, 'warn'

error = innerLog.bind console, 'error'

time = (label) ->
    times[label] = now()

timeEnd = (label) ->
    `var time`
    time = times[label]
    if !time
        throw new Error('No such label: ' + label)
    duration = now() - time
    console.log label + ': ' + duration + 'ms'

trace = ->
    err = new Error
    err.name = 'Trace'
    err.message = util.format.apply(null, arguments)
    console.error err.stack

dir = (object) ->
    console.log util.inspect(object) + '\n'

consoleAssert = (expression) ->
    if !expression
        arr = slice.call(arguments, 1)
        assert.ok false, util.format.apply(null, arr)

if typeof global != 'undefined' and global.console
    console = global.console
else if typeof window != 'undefined' and window.console
    console = window.console
else
    console = {}

functions = [
    [ log, 'log' ]
    [ info, 'info' ]
    [ warn, 'warn' ]
    [ error, 'error' ]
    [ time, 'time' ]
    [ timeEnd, 'timeEnd' ]
    [ trace, 'trace' ]
    [ dir, 'dir' ]
    [ consoleAssert, 'assert' ]
]

for tuple in  functions
    f = tuple[0]
    name = tuple[1]
    if !console[name]
        console[name] = f

module.exports = console
