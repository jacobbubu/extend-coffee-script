logServer = require './logServer'
apiServer = require './apiServer'

{ LOG_PORT, API_PORT } = process.env

logServer.start LOG_PORT, ->
    console.log 'log server is listening on port', LOG_PORT

apiServer.start API_PORT, ->
    console.log 'api server is listening on port', API_PORT