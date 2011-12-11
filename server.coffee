http = require 'http'
fs = require 'fs'
path = require 'path'
mime = require 'mime'
reed = require 'reed'

port = process.env.PORT || 3000

reedcontent = (callback) ->
    reed.all (error, posts) ->
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
                  section = []
                  mtime = 0
                  append = (post) ->
                    section.push '<section id=' + post.metadata.id+'>'
                    swe = post.htmlContent.indexOf('<h2')
                    eng = post.htmlContent.indexOf('<h2', swe + 1);
                    section.push '<div class="swe">'
                    section.push post.htmlContent.substring swe, eng
                    section.push '</div>'
                    section.push '<div class="eng">'
                    section.push post.htmlContent.substring eng
                    section.push '</div>'
                    section.push '</section>'
                    mtime = post.metadata.lastModified if post.metadata.lastModified > mtime
                  append post for post in posts
                  sections = section.join ''
                  content = content.toString 'utf-8'
                  content = content.replace '%SECTIONS%', sections
                  content = new Buffer(content, 'utf-8')
                  send content, mtime
              else
                send content, mtime

reed.on "ready", () ->
  http.createServer(server).listen(port)

reed.open './posts'

console.log 'Listening to: '+port
