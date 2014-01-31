express = require 'express'
http = require 'http'
assert = require 'assert'
fs = require 'fs'
file = __filename.replace('/server.coffee', '') + '/balls.json'
balls = {}

fs.readFile file, 'utf8', (err, data) ->
  if err
    console.log 'Error: ' + err
    return
 
  balls = JSON.parse data
  console.log balls

write_balls = () ->
  console.log "writing to file"
  console.log balls
  fs.writeFile file, JSON.stringify(balls, null, 4), (err) ->
      if err
        console.log err
      else
        console.log "JSON saved to #{file}"

# setInterval write_balls, 10000

setup_server = () ->

  app = express()

  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

  new_ball = (name) ->
    return {ball_name: name, holder : false, list: []}

  app.get '/balls', (req, res) ->
    console.log "-- someones lookin at balls"
    res.send balls

  app.get '/:user_name/hold/:ball_name', (req, res) ->
    user_name = "#{req.params.user_name}"
    ball_name = "#{req.params.ball_name}"
    console.log "-- #{user_name} holds #{ball_name}"
    
    if not (ball_name of balls)
      balls[ball_name] = new_ball ball_name

    if balls[ball_name].holder == false
      
      if balls[ball_name].list.length == 0
        balls[ball_name].holder = user_name
        write_balls()
      
      else if balls[ball_name].list[0] == user_name
        balls[ball_name].list.shift()
        balls[ball_name].holder = user_name
        write_balls()
      
      else
        res.status(405)
    else
      res.status(405)
      
    res.send balls[ball_name]

  app.get '/:user_name/put/:ball_name', (req, res) ->
    user_name = "#{req.params.user_name}"
    ball_name = "#{req.params.ball_name}"
    console.log "-- #{user_name} puts #{ball_name}"
    
    if not (ball_name of balls)
      balls[ball_name] = new_ball ball_name

    if balls[ball_name].holder == user_name
      balls[ball_name].holder = false
      write_balls()

    else
      res.status(405)
    
    res.send balls[ball_name]

  app.get '/:user_name/wait_for/:ball_name', (req, res) ->
    user_name = "#{req.params.user_name}"
    ball_name = "#{req.params.ball_name}"
    console.log "-- #{user_name} waits for #{ball_name}"
    
    if not (ball_name of balls)
      balls[ball_name] = new_ball ball_name

    if balls[ball_name].holder == false
      res.status(405)
    
    else
      balls[ball_name].list.push(user_name)
      write_balls()
       
    res.send balls[ball_name]

  app.get '/balls/:ball_name', (req, res) ->
    ball_name = "#{req.params.ball_name}"
    console.log "-- see #{ball_name}"
    if ball_name of balls
      res.send balls[ball_name]
    else
      res.status(404)
      res.send {'error': 'no ball'}

  app.get '/balls/:ball_name/drop', (req, res) ->
    ball_name = "#{req.params.ball_name}"
    console.log "-- drop #{ball_name}"
    if ball_name of balls
      b = balls[ball_name]
      delete balls[ball_name]
      write_balls()
      res.send b
    else
      res.status(404)
      res.send {'error': 'no ball'}

  app.get '/balls/:ball_name/clear', (req, res) ->
    ball_name = "#{req.params.ball_name}"
    console.log "-- clear #{ball_name} queue"
    if ball_name of balls
      balls[ball_name].holder = false
      balls[ball_name].list = []
      write_balls()
      res.send balls[ball_name]
    else
      res.status(404)
      res.send {'error': 'no ball'}

  app.use (req, res) ->
    console.log "-- unrecognized"
    res.status(404)
    res.send {'status': 'not found'}

  port = process.env.HTTP_PORT || 8080
  app.listen port
  console.log "Listening on port #{port}"

setup_server()
