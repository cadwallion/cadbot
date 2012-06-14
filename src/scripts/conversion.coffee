# Converts money
#
# <AMOUNT><CURRENCY> in <CURRENCY> - Converts from one currency to the other
module.exports = (bot) ->
  bot.respond /([\d|\.|\,]+)(\w+) in (\w)/i, (msg) ->
    from = msg.matches[0] + msg.matches[1]
    to = msg.matches[2]
    msg.http("http://www.google.com/ig/calculator?hl=en&q=#{from}=?#{to}")
      .get() (e, r, b) ->
        try
          json = JSON.parse b
          msg.send "#{json.lhs} = #{json.rhs}"
        catch error
          msg.send "I'm sorry, I can't seem to find that conversion."
