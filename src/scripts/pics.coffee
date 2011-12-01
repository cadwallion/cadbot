Redis = require 'redis'
Url   = require 'url'

module.exports = (robot) ->

  info   = Url.parse process.env.REDISTOGO_URL || 'redis://localhost:6379'
  client = Redis.createClient(info.port, info.hostname)

  if info.auth
      client.auth info.auth.split(":")[1]

  robot.respond /pic ([\S-]+)$/, (msg) ->
    if msg.match[1] is 'list'
      client.hkeys "pics", (err, pics) ->
        if pics?
          msg.send pics.join ", "
        else
          msg.send "no pics currently in my system"
    else
      client.hget "pics", msg.match[1], (err, pic) ->
        if err
         msg.send "An error occurred retrieving picture"
        else if pic == undefined
          msg.send "Picture not set for #{msg.match[1]}, please set with 'pic set NAME URL'"
        else
          msg.send pic
  robot.respond /pic set ([\S-]+) (.+)$/, (msg) ->
    client.hset "pics", msg.match[1], msg.match[2], (err) ->
        msg.send "Pic #{msg.match[1]} set."

