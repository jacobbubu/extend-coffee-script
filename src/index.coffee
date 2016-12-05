require 'coffee-script/register'

fs = require 'fs'
os = require 'os'
path = require 'path'

# Inject to babel-generator to fix logical operator precedence issue
# in Adoboe ExtendScript
rj = require 'require-injector'
rj { basedir: __dirname }
rj.fromPackage 'babel-generator'
    .substitute './parentheses', path.resolve(__dirname, '../vendors/parentheses')

extendScript = require 'commander'
packageJson = require '../package.json'
browserify = require 'browserify'
prependify = require 'prependify'
coffeeify = require './coffeeify'
concat = require 'concat-stream'

extendScript
    .version(packageJson.version)
    .usage '[options]'
    .option '-s, --script <path>', 'The input file to compile into an executable extendscript'
    .option '-t, --target <targetName>', 'In which Adobe Application you want your script to run'
    .option '-o, --output [path]', 'The path to the wished compiled output file'
    .option '-p, --prepend [path]', 'You can inject any ExtendScript into the code header'
    .parse process.argv

console.log 'Running extend-coffee-script with following options:'

extendScript.options.forEach (opt) ->
    return if opt.long is '--version'
    optionName = opt.long.replace '--', ''
    console.log(
        opt.long + ': ' +
        extendScript[optionName] +
        if opt.optional is 0 then '' else ' (optional)'
    )

if !extendScript.target
    throw new Error 'Target application MUST be specified'

browserifyPlugins = []
if extendScript.prepend?
    prepandPath = path.resolve process.cwd(), extendScript.prepend
    if !fs.existsSync(prepandPath)
        throw new Error 'Prepending file is not existing', prepandPath

    browserifyPlugins.push [
        prependify
        require(prepandPath) + os.EOL
    ]

b = browserify {
    entries: [
        './node_modules/ps-scripting-es5shim/index.js'
        path.resolve process.cwd(), extendScript.script
    ]
    extensions: ['.coffee']
    transform: [
        [coffeeify, bare: false]
        ['babelify', { global: true, comments: false }]
    ]
    plugin: browserifyPlugins
    insertGlobalVars:
        JSON: (file, basedir) ->
            modulePath = path.resolve __dirname, '../vendors/json2'
            "require('#{modulePath}')"
        console: (file, basedir) ->
            modulePath = path.resolve __dirname, './console-browserify'
            "require('#{modulePath}')"
}

b.bundle().pipe concat (script) ->
    script =  script.toString()
    console.log 'extendScript.output', extendScript.output
    if extendScript.output?
        fs.writeFileSync extendScript.output, script, 'utf-8'

    runInTarget = require './runInTarget'
    runInTarget extendScript.target, script, (err, res) ->
        if err?
            console.error 'Error', err
        else
            console.error 'Done', res