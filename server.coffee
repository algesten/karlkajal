http = require 'http'
fs = require 'fs'
path = require 'path'
mime = require 'mime'
url = require 'url'
reed = require 'reed'

indexPage = require './index-page'
feedPage = require './feed-page'

port = process.env.PORT || 3000

reedcontent = (callback) ->
    reed.all (error, posts) ->

      for post in posts
        do (post) ->
          parts = (/(\d{4})(\d{2})(\d{2})/).exec(post.metadata.id);
          date = new Date(0);
          date.setUTCFullYear(parts[1]);
          date.setUTCMonth(parts[2] - 1);
          date.setUTCDate(parts[3]);
          post.metadata.date = date;

      callback posts.sort (a,b) ->
        aid = a.metadata.id
        bid = b.metadata.id
        if aid < bid then -1 else if aid == bid then 0 else 1

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

              send = (toSend, mtime) ->
                response.writeHead(200,{
                  'Content-Type': contentType,
                  'Content-Length': toSend.length,
                  'Date': (new Date()),
                  'Expires': (new Date(Date.now() + 600 * 1000)),
                  'Cache-Control':  'public, max-age=600',
                  'Last-Modified':  stat.mtime
                })
                response.end(content)

              if filePath == './index.html'
                reedcontent (posts) ->
                  [content, mtime] = indexPage.sections posts, content
                  send content, mtime
              else if filePath == './feed.xml'
                reedcontent (posts) ->
                  [content, mtime] = feedPage.sections posts, content
                  send content, mtime
              else
                send content, mtime

reed.on "ready", () ->
  http.createServer(server).listen(port)

if process.env.REDISTOGO_URL
  parsed = url.parse(process.env.REDISTOGO_URL);
  reed.configure {
    host: parsed.hostname
    port: parsed.port
    password: parsed.auth.split(':')[1]
  }

reed.open './posts'

console.log 'Listening to: '+port
