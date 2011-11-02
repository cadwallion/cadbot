# Freeweatheronline.com integration
#
# weather <query> - can be US/CA/UK postal code or city/region
#
request = require('request')
querystring = require('querystring')

module.exports = (robot) ->
  robot.respond /(weather|forecast)( .+)?/i, (msg) ->
    code = Weather.parseCode(msg)
    if code?
      Weather[msg.match[1]] code
    else
      msg.send "You did not supply a location, and I have no location on file"
  robot.respond /my location is (.+)/i, (msg) ->
    msg.message.user.location = msg.match[1]
    msg.send "Your location has been saved"

Weather =
  parseCode: (msg) ->
    code = msg.match[2]
    if code?
      return code.toString().replace(/^\s/,'')
    else
      if msg.message.user.location?
        return msg.message.user.location
      else
        return null

  report: (code) ->
    @weather code, (data) =>
      item = data.current_condition[0]
      location = @region data.nearest_area[0]
      condition = item.weatherDesc[0].value
      windSpeed = "#{item.winddir16Point} wind at #{item.windspeedKmph}kmph/#{item.windspeedMiles}mph"

      response = "#{location}: #{item.temp_C}C/#{item.temp_F}F and #{condition} with #{windSpeed}"
      msg.send response
  forecast: (code) ->
    @weather code, (data) =>
      location = @region data.nearest_area[0]
      msg.send "Forecast for #{location}:"
      for item, idx in data.weather
        condition = item.weatherDesc[0].value
        windSpeed = "#{item.winddir16Point} wind at #{item.windspeedKmph}kmph/#{item.windspeedMiles}mph"
        msg.send "#{item.data}: #{condition} and #{item.temp_C}C/#{item.temp_F}F with #{windSpeed}"

  weather: (code, callback) ->
    url = "http://free.worldweatheronline.com/feed/weather.ashx?q=#{code}&cc=yes&format=json&includeLocation=yes&key=ece8d8682c193256112104&num_of_days=5"
    request url, (error, res, body) =>
      data = JSON.parse(body).data
      if data.error?
        msg.send "That place does not seem to exist in this reality"
      else
        callback(data)
  region: (nearest_area) ->
    if nearest_area.region?
      region = "#{nearest_area.region[0].value}, "
    else
      region = ""
    return "#{nearest_area.areaName[0].value}, #{region}#{nearest_area.country[0].value}"

