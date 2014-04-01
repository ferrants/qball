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

  get_time = () ->
    return (new Date()).toJSON()

  new_ball = (name) ->
    return {
      ball_name: name,
      holder : false,
      list: [],
      last_modified: get_time(),
      auto_admin: false,
      message: "ball created"
    }

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
        balls[ball_name].last_modified = get_time()
        balls[ball_name].message = "#{user_name} held the ball"
        write_balls()
      
      else if balls[ball_name].list[0] == user_name
        balls[ball_name].list.shift()
        balls[ball_name].holder = user_name
        balls[ball_name].last_modified = get_time()
        balls[ball_name].message = "#{user_name} held the ball"
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
      balls[ball_name].last_modified = get_time()
      balls[ball_name].message = "#{user_name} released the ball"
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

    if user_name in balls[ball_name].list or balls[ball_name].holder == user_name or (balls[ball_name].holder == false and balls[ball_name].list.length == 0)
      res.status(405)
    
    else
      balls[ball_name].list.push(user_name)
      balls[ball_name].message = "#{user_name} joined the line"
      write_balls()
       
    res.send balls[ball_name]

  app.get '/:user_name/stop_wait_for/:ball_name', (req, res) ->
    user_name = "#{req.params.user_name}"
    ball_name = "#{req.params.ball_name}"
    console.log "-- #{user_name} stops waiting for #{ball_name}"
    if not (ball_name of balls)
      res.status(405)
    else if not (user_name in balls[ball_name].list)
      res.status(405)
    else
      balls[ball_name].list.splice(balls[ball_name].list.indexOf(user_name), 1)
      balls[ball_name].message = "#{user_name} left the line"
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
      balls[ball_name].last_modified = get_time()
      balls[ball_name].message = "ball was cleared"
      write_balls()
      res.send balls[ball_name]
    else
      res.status(404)
      res.send {'error': 'no ball'}

  app.get '/balls/:ball_name/kick', (req, res) ->
    ball_name = "#{req.params.ball_name}"
    console.log "-- kick holder of #{ball_name}"
    if ball_name of balls
      balls[ball_name].message = "#{balls[ball_name].holder} kicked as holder"
      balls[ball_name].holder = false
      write_balls()
      res.send balls[ball_name]
    else
      res.status(404)
      res.send {'error': 'no ball'}

  app.get '/balls/:ball_name/rotate', (req, res) ->
    ball_name = "#{req.params.ball_name}"
    console.log "-- rotate queue of #{ball_name}"
    if ball_name of balls
      b = balls[ball_name].list.shift()
      if b
        balls[ball_name].list.push(b)
      balls[ball_name].message = "ball queue rotated"
      write_balls()
      res.send balls[ball_name]
    else
      res.status(404)
      res.send {'error': 'no ball'}

  app.get '/balls/:ball_name/auto_admin', (req, res) ->
    ball_name = "#{req.params.ball_name}"
    console.log "-- toggle auto_admin for #{ball_name}"
    if ball_name of balls
      balls[ball_name].auto_admin = !balls[ball_name].auto_admin

      if !balls[ball_name].last_modified
        balls[ball_name].last_modified = get_time()

      if !balls[ball_name].auto_admin_holder_limit
        balls[ball_name].auto_admin_holder_limit = 3600000

      if !balls[ball_name].auto_admin_queue_lead_limit
        balls[ball_name].auto_admin_queue_lead_limit = 60000

      balls[ball_name].message = "auto_admin set to #{balls[ball_name].auto_admin}"
      write_balls()
      res.send balls[ball_name]
    else
      res.status(404)
      res.send {'error': 'no ball'}

  app.get '/balls/:ball_name/auto_admin_holder_limit/:limit', (req, res) ->
    ball_name = "#{req.params.ball_name}"
    console.log "-- set auto_admin_holder_limit for #{ball_name}"
    if ball_name of balls
      balls[ball_name].auto_admin_holder_limit = parseInt(req.params.limit, 10)
      balls[ball_name].message = "auto_admin_holder_limit set to #{req.params.limit} ms"
      write_balls()
      res.send balls[ball_name]
    else
      res.status(404)
      res.send {'error': 'no ball'}

  app.get '/balls/:ball_name/auto_admin_queue_lead_limit/:limit', (req, res) ->
    ball_name = "#{req.params.ball_name}"
    console.log "-- set auto_admin_queue_lead_limit for #{ball_name}"
    if ball_name of balls
      balls[ball_name].auto_admin_queue_lead_limit = parseInt(req.params.limit, 10)
      balls[ball_name].message = "auto_admin_queue_lead_limit set to #{req.params.limit} ms"
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

  auto_admin_check = () ->
    console.log "-- auto_admin check"
    for ball_name, ball of balls
      if ball.auto_admin
        last = new Date(ball.last_modified);
        current = new Date()
        if ball.holder != false and current - last > ball.auto_admin_holder_limit
          ball.message = "auto_admin removed #{ball.holder} as holder after #{(current - last) / 60000} minutes holding it"
          console.log ball.message
          balls[ball_name].last_modified = get_time()
          ball.holder = false
          write_balls()
        else if ball.holder == false and balls[ball_name].list.length > 1 and current - last > ball.auto_admin_queue_lead_limit
          ball.message = "auto_admin rotated queue because #{balls[ball_name].list[0]} was unresponsive after #{(current - last) / 1000} seconds being first"
          console.log ball.message
          b = ball.list.shift()
          if b
            ball.list.push(b)
          write_balls()

  check_interval = process.env.CHECK_INTERVAL || 30000
  setInterval auto_admin_check, check_interval
  console.log "Check Interval set at #{check_interval} ms"

setup_server()
