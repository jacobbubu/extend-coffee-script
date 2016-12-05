fs = require 'fs'
spawn = require('child_process').spawn

module.exports = (target, script, cb) ->
    target = target.toLowerCase()
    target = 'Adobe ' + target[0].toUpperCase() + target[1..]

    cliArgs = []

    cliArgs.push '-e', 'on run argv'
    cliArgs.push '-e',   'with timeout of 600 seconds'
    cliArgs.push '-e',     "tell application \"#{target}\" to do javascript (item 1 of argv)"
    cliArgs.push '-e',   'end timeout'
    cliArgs.push '-e', 'end run'

    cliArgs.push script

    child = spawn '/usr/bin/osascript', cliArgs

    _output = ''
    child.stdout.on 'readable', -> _output = this.read()

    _error = ''
    child.stderr.on 'data', (data) -> _error += data

    child.on 'exit', (code) ->
        if _error
            cb? stderr: _error
        else
            cb? null, { code, stdout: _output }
