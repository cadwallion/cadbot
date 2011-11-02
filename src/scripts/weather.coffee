# Freeweatheronline.com integration
#
# weather <query> - can be US/CA/UK postal code or city/region
#
request = require('request')
querystring = require('querystring')

module.exports = (robot) ->
  robot.respond /weather (.+)/i, (msg) ->
    code = querystring.escape msg.match[1]
    url = "http://free.worldweatheronline.com/feed/weather.ashx?q=#{code}&cc=yes&format=json&includeLocation=yes&key=ece8d8682c193256112104"
    request url, (error, res, body) =>
      data = JSON.parse(body).data
      if data.error?
        msg.send "That place does not seem to exist in this reality"
      else
        item = data.current_condition[0]
        nearest_area = data.nearest_area[0]

        if nearest_area.region?
          region = "#{nearest_area.region[0].value}, "
        else
          region = ""
        location = "#{nearest_area.areaName[0].value}, #{region}#{nearest_area.country[0].value}"
        condition = item.weatherDesc[0].value
        windSpeed = "#{item.winddir16Point} wind at #{item.windspeedKmph}kmph/#{item.windspeedMiles}mph"
        response = "#{location}: #{item.temp_C}C/#{item.temp_F}F and #{condition} with #{windSpeed}"
        msg.send response
