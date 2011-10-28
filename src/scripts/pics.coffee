redis = require('redis').createClient()

module.exports = (robot) ->
  robot.respond /pic ([\S-]+)$/, (msg) ->
    if msg.match[1] is 'list'
      redis.hkeys "pics", (err, pics) ->
        if pics?
          msg.send pics.join ", "
        else
          msg.send "no pics currently in my system"
    else
      redis.hget "pics", msg.match[1], (err, pic) ->
        if err
         msg.send "An error occurred retrieving picture"
        else if pic == undefined
          msg.send "Picture not set for #{msg.match[1]}, please set with 'pic set NAME URL'"
        else
          msg.send pic
  robot.respond /pic set ([\S-]+) (.+)$/, (msg) ->
    redis.hset "pics", msg.match[1], msg.match[2], (err) ->
        msg.send "Pic #{msg.match[1]} set."

