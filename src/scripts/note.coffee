# Note passing system for the next time someone speaks
#
# tell X that Y - saves a note to relay to person X
#
module.exports = (robot) ->
  robot.respond /tell (.+) that (.+)/, (msg) ->
    from = msg.message.user
    to = msg.match[1]
    message = msg.match[2]

    user = robot.brain.userForName to
    user.notes ||= []
    user.notes.push
      from: from
      message: message

    msg.send "I will convey your message when next I see #{to}."

  robot.hear //, (msg) ->
    speaker = msg.message.user
    for note in speaker.notes
      msg.send "#{note['from']} says to tell you that '#{note['message']}'."
      speaker.notes = []
