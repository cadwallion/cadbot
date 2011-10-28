Fs        = require 'fs'
Path      = require 'path'
Hubot     = require 'hubot'

module.exports =
  load: () ->
    @loadConfig () =>
      @loadBot()
      @loadScripts()
      @run()

  loadConfig: (callback) ->
    self = @
    configFile = Path.resolve 'config.json'
    Path.exists configFile, (exists) ->
      if exists
        Fs.readFile configFile, (err, data) ->
          self.config = JSON.parse data
          counter = 0
          for envvar, value of self.config.envvars
            process.env["HUBOT_#{envvar}"] = value
            console.log("ENV: #{envvar} - #{process.env["HUBOT_#{envvar}"]}")
          callback()
      else
        console.log('A config.json must be established. See example.config.json')
        process.exit(1)

  loadBot: () ->
    scriptsPath = Path.resolve './src/scripts'
    console.log "loading scripts in #{scriptsPath}"
    @robot     = Hubot.loadBot @config.adapter, scriptsPath, @config.name

  loadScripts: () ->
    self = @
    scriptsFile = Path.resolve 'hubot-scripts.json'
    Fs.readFile scriptsFile, (err, data) ->
      JSON.parse(data).forEach (plugin) ->
        console.log "Testing for existence of #{Path.resolve('node_modules', 'hubot-scripts', 'src', 'scripts', plugin)}"
        Path.exists Path.resolve('node_modules', 'hubot-scripts', 'src', 'scripts', plugin), (exists) ->
          if exists
            console.log "loading #{plugin}"
            self.robot.loadFile Path.resolve("node_modules", "hubot-scripts", "src", "scripts"), plugin
          else
            console.log "#{plugin} does not exist, testing in hubot core scripts"
            Path.exists Path.resolve('node_modules', 'hubot', 'src', 'hubot', 'scripts', plugin), (exists) ->
              if exists
                console.log "Loading #{plugin}"
                self.robot.loadFile Path.resolve('node_modules', 'hubot', 'src', 'hubot', 'scripts'), plugin
              else
                console.log "#{plugin} not found in any core locations"
  run: () ->
    @robot.run()
