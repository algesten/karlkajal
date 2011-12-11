http = require 'http'
fs = require 'fs'
path = require 'path'
mime = require 'mime'

port = process.env.PORT || 3000

server = (request, response) ->

  filePath = '.' + request.url
  filePath = './index.html' if filePath == './'

  extname = path.extname filePath

  path.exists filePath, (exists) ->

    if !exists

      response.writeHead(404)
      response.end()

    else

      contentType = mime.lookup extname
      contentType += ';charset=UTF-8' if contentType.indexOf('text/') == 0

      fs.stat filePath, (err1, stat) ->

        mtime = stat.mtime
        mtime = new Date(stat.mtime) if mtime

        ifmodified = request.headers['if-modified-since']
        ifmodified = new Date(ifmodified) if ifmodified

        if ifmodified && mtime && Math.abs(ifmodified.getTime() - mtime.getTime()) < 1000

          response.writeHead(304)
          response.end()

        else

          fs.readFile filePath, (err2, content) ->

            if err2
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

http.createServer(server).listen(port)

console.log 'Listening to: '+port
