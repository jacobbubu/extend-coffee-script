parseStatusLine = (statusLine) ->
    parts = statusLine.match /^(.+) ([0-9]{3}) (.*)$/
    parsed = {}

    if parts?
        parsed['protocol'] = parts[1]
        parsed['statusCode'] = parts[2]
        parsed['statusMessage'] = parts[3]

    parsed

parseHeaders = (headerLines) ->
    headers = {}
    for line in headerLines
        parts = line.split ':'
        key = parts.shift()
        headers[key] = parts.join(':').trim()
    headers

parse = (responseString) ->
    response = {}
    lines = responseString.split '\n'

    parsedStatusLine = parseStatusLine lines.shift()
    response['protocolVersion'] = parsedStatusLine['protocol']
    response['statusCode'] = parsedStatusLine['statusCode']
    response['statusMessage'] = parsedStatusLine['statusMessage']

    headerLines = []
    while lines.length > 0
        line = lines.shift()
        break if line is ''
        headerLines.push line

    response['headers'] = parseHeaders headerLines
    response['body'] = lines.join '\n'

    response

module.exports = parse