
module.exports.sections = (posts, content) ->
  section = []
  mtime = 0
  append = (post) ->
    section.push '<section id=' + post.metadata.id + '>'
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
  [content, mtime]
