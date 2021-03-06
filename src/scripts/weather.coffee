# Freeweatheronline.com integration
#
# weather <query> - can be US/CA/UK postal code or city/region
#
request = require('request')
querystring = require('querystring')

module.exports = (robot) ->
  robot.respond /(weather|forecast)( .+)?/i, (msg) ->
    weather = new Weather(msg)
    weather[msg.match[1]]()

  robot.respond /my location is (.+)/i, (msg) ->
    msg.message.user.location = msg.match[1]
    msg.send "Your location has been saved as #{msg.message.user.location}"

  robot.respond /what is my location\?/i, (msg) ->
    user = msg.message.user
    if user.location?
      msg.send "Your location is: #{user.location}"
    else
      msg.send "I do not have a location on file for you"

class Weather
  constructor: (@msg) ->
    @parseCode()

  parseCode: ->
    code = @msg.match[2]
    if code?
      @code = querystring.escape code.toString().replace(/^\s/,'')
    else
      if @msg.message.user.location?
        @code = @msg.message.user.location
      else
        @msg.send "You did not supply a location, and I have no location on file"

  weather: ->
    if @code?
      @get (data) =>
        location = @region data.nearest_area[0]
        item = data.current_condition[0]
        condition = item.weatherDesc[0].value
        windSpeed = "#{item.winddir16Point} wind at #{item.windspeedKmph}kmph/#{item.windspeedMiles}mph"
        dayForecast = data.weather[0]
        expected =
          highC: dayForecast.tempMaxC
          highF: dayForecast.tempMaxF
          lowC:  dayForecast.tempMinC
          lowF:  dayForecast.tempMinF
        forecastString = "Expected Temps: High #{expected.highC}C/#{expected.highF}F, Low #{expected.lowC}C/#{expected.lowF}F"
        @msg.send "#{location}: #{condition}, #{item.temp_C}C/#{item.temp_F}F with #{windSpeed}. #{forecastString}"
      
  forecast: ->
    if @code?
      @get (data) =>
        location = @region data.nearest_area[0]
        @msg.send "Forecast for #{location}:"
        for item, idx in data.weather
          condition = item.weatherDesc[0].value
          windSpeed = "#{item.winddir16Point} wind at #{item.windspeedKmph}kmph/#{item.windspeedMiles}mph"
          @msg.send "#{item.date}: #{condition}, High #{item.tempMaxC}C/#{item.tempMaxF}F, Low #{item.tempMinC}C/#{item.tempMinF}F with #{windSpeed}"

  get: (callback) ->
    url = "http://free.worldweatheronline.com/feed/weather.ashx?q=#{@code}&cc=yes&format=json&includeLocation=yes&key=ece8d8682c193256112104&num_of_days=5"
    request url, (error, res, body) =>
      if error?
        @msg.send "I cannot process something in your request"
      else
        try
          data = JSON.parse(body).data
          if data.error?
            @msg.send "That place does not seem to exist in this reality"
          else
            callback(data)
        catch error
          @msg.send "I cannot process somethign in your request"

  region: (nearest_area) ->
    if nearest_area.region?
      region = "#{nearest_area.region[0].value}, "
    else
      region = ""
    return "#{nearest_area.areaName[0].value}, #{region}#{nearest_area.country[0].value}"
