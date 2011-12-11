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

      statFile = (error, stat) ->

        mtime = stat.mtime
        mtime = new Date(stat.mtime) if mtime;

        ifmodified = request.headers['if-modified-since']
        ifmodified = new Date(ifmodified) if ifmodified

        if ifmodified && mtime && Math.abs(ifmodified.getTime() - mtime.getTime()) < 1000

          response.writeHead(304)
          response.end()

        else

          sendfile = (error, content) ->

            if error
              response.writeHead(500)
            else
              response.writeHead(200,{
                'Content-Type': contentType,
                'Content-Length': content.length,
                'Date': (new Date()),
                'Expires': (new Date(Date.now() + 600 * 1000)),
                'Cache-Control':  'public, max-age=600',
                'Last-Modified':  stat.mtime
              })
            response.end(content)

          fs.readFile(filePath, sendfile)

      fs.stat(filePath, statFile)

    else
      response.writeHead(404)
      response.end()

  path.exists(filePath,output)

port = process.env.PORT || 3000;
http.createServer(serv).listen(port)

console.log 'Listening to: '+port
