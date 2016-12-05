express = require 'express'
app = express()

app.get '/about', (req, res) ->
    console.log 'got request', req.url
    res.send { message: 'SkinAT adobe Server' }

app.get '/', (req, res) ->
    console.log '404', req.url
    res.status(404).send 'Not found'

module.exports =
    start: (port, host, cb)->
        if typeof host is 'function'
            cb = host
            host = '127.0.0.1'
        host ?= '127.0.0.1'
        app.listen port, host, cb
