URL = require 'url'
parse = require './httpParser'

loadURL = (url, callback) ->
    parsed = URL.parse url

    bt = new BridgeTalk()
    bt.target = 'bridge'

    script = """
        var result = '';
        var LN = String.fromCharCode(10);
        var socket = new Socket();
        $.writeln('#{parsed.host}')
        if (socket.open('#{parsed.host}')) {
            headers = [
                'GET #{parsed.path} HTTP/1.0',
                'Host: #{parsed.host}',
                'Content-Length: 0',
                'Content-Type: application/json'
            ];
            socket.write(headers.join(LN) + LN + LN);
            result = socket.read(9999999);
            socket.close();
        }
        result;
    """

    bt.body = script

    bt.onResult = (inBT) ->
        callback null, parse inBT.body
    bt.onError = (inBT) -> callback inBT.body, null
    bt.send 5000

module.exports = loadURL
