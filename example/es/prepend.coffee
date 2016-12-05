module.exports = """
    var CONFIG = {
        logServer: {
            port: #{process.env.LOG_PORT},
            host: '#{process.env.LOG_HOST ? '127.0.0.1'}'
        },
        apiServer: {
            port: #{process.env.API_PORT},
            host: '#{process.env.API_HOST ? '127.0.0.1'}'
        }
    };

"""