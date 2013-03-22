# Description:
#   Espouse a short piece of quality programming wisdom.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot wisdom - Make everyone a better developer.
#
# Author:
#   pizzeys

module.exports = (robot) ->
  robot.respond /wisdom/i, (msg) ->
    msg.http('https://api.twitter.com/1/statuses/user_timeline.json')
      .query(screen_name:'shit_hn_says', count: 1000)
      .get() (err, res, body) ->
        tweets = JSON.parse(body)
        tweet = msg.random tweets

        msg.send tweet.text
