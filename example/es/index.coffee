parser = require './httpParser'
loadURL = require './loadURL'

done = (err, res) ->
    if err
        console.log 'FAILED', err
    else
        console.log JSON.parse res.body

loadURL "http://#{CONFIG.apiServer.host}:#{CONFIG.apiServer.port}/about", done
