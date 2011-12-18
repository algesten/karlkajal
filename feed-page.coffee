dateformat = require 'dateformat'
uuid = require 'node-uuid'

module.exports.sections = (posts, content) ->
  entries = []
  mtime = 0
  append = (post) ->

    swe1 = 4 + post.htmlContent.indexOf '<h2'
    swe2 = post.htmlContent.indexOf '</h2>', swe1 + 1
    eng1 = 4 + post.htmlContent.indexOf '<h2', swe2 + 1
    eng2 = post.htmlContent.indexOf '</h2>', eng1 + 1
    date = post.metadata.date

    id = uuid.v1 {
      node: [0x01, 0x23, 0x45, 0x67, 0x89, 0xab]
      msecs: date
    }

    entries.push '<entry>\n'
    entries.push '<title>'
    entries.push post.htmlContent.substring swe1, swe2
    entries.push ' | '
    entries.push post.htmlContent.substring eng1, eng2
    entries.push '</title>\n'
    entries.push '<link href="http://kajal.algesten.se/index.html#' + post.metadata.id + '" />\n'
    entries.push '<id>urn:uuid:' + id + '</id>\n'
    entries.push '<updated>' + (dateformat date, "isoDateTime", true) + '</updated>\n'
    entries.push '</entry>\n\n'

    mtime = date if date > mtime

  append post for post in posts
  entries = entries.join ''
  content = content.toString 'utf-8'
  content = content.replace '%ENTRIES%', entries
  content = content.replace '%UPDATED', dateformat mtime, "isoDateTime", true
  content = new Buffer(content, 'utf-8')
  [content, mtime]
