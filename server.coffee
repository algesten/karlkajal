http = require 'http'
fs = require 'fs'
path = require 'path'
mime = require 'mime'
 
serv = (request, response) -> 

    filePath = '.' + request.url
    filePath = './index.html' if filePath == './'    

    extname = path.extname filePath

    output = (exists) -> 
        if exists
            contentType = mime.lookup extname
            contentType += ';charset=UTF-8' if contentType.indexOf('text/') == 0
            sendfile = (error, content) ->
                if error
                    response.writeHead(500)
                    response.end()
                else
                    response.writeHead(200,{ 
                        'Content-Type': contentType,
                        'Content-Length': content.length,
                        'Date': (new Date()),
                        'Expires': (new Date(Date.now() + 600 * 1000)),
                        'Cache-Control':  'public, max-age=600'
                    })
                    response.end(content)
            fs.readFile(filePath, sendfile)

        else
            response.writeHead(404)
            response.end()

    path.exists(filePath,output)

port = process.env.PORT || 3000;
http.createServer(serv).listen(port)

console.log 'Listening to: '+port
