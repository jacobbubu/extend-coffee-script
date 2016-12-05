coffee = require 'coffee-script'
convert = require 'convert-source-map'
path = require 'path'
through = require 'through2'
filePattern = /\.((lit)?coffee|coffee\.md)$/

isCoffee = (file) ->
    filePattern.test file

isLiterate = (file) ->
    /\.(litcoffee|coffee\.md)$/.test file

ParseError = (error, src, file) ->
    SyntaxError.call this

    @message = error.message
    @line = error.location.first_line + 1
    # cs linenums are 0-indexed
    @column = error.location.first_column + 1
    # same with columns
    markerLen = 2

    if error.location.first_line is error.location.last_line
        markerLen += error.location.last_column - error.location.first_column

    @annotated = [
        file + ':' + @line
        src.split('\n')[@line - 1]
        Array(@column).join(' ') + Array(markerLen).join('^')
        'ParseError: ' + @message
    ].join('\n')

compile = (filename, source, options, callback) ->
    try
        compiled = coffee.compile(source,
            sourceMap: options.sourceMap
            inline: true
            bare: options.bare
            header: options.header
            literate: isLiterate filename
        )
    catch e
        error = if e.location then new ParseError(e, source, filename) else e
        return callback error

    if options.sourceMap
        map = convert.fromJSON compiled.v3SourceMap
        basename = path.basename filename
        map.setProperty 'file', basename.replace(filePattern, '.js')
        map.setProperty 'sources', [ basename ]
        callback null, compiled.js + '\n' + map.toComment() + '\n'
    else
        callback null, compiled + '\n'

coffeeify = (filename, options) ->
    options ?= {}
    chunks = []

    transform = (chunk, encoding, callback) ->
        chunks.push chunk
        callback()

    flush = (callback) ->
        stream = this
        source = Buffer.concat(chunks).toString()
        compile filename, source, compileOptions, (error, result) ->
            stream.push result if !error

            return callback error

    return through() if !isCoffee(filename)

    compileOptions =
        sourceMap: options._flags and options._flags.debug
        bare: true
        header: false

    for key of compileOptions
        option = options[key]
        if option?
            option = false if option in ['false', 'no', '0']
            compileOptions[key] = !!option

    through transform, flush

ParseError.prototype = Object.create SyntaxError.prototype

ParseError::toString = -> @annotated
ParseError::inspect = -> @annotated

coffeeify.compile = compile
coffeeify.isCoffee = isCoffee
coffeeify.isLiterate = isLiterate
module.exports = coffeeify
