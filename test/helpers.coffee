logger = {}
logger.log = (s) -> 
	# console.log s

exports.generate_string = (len=5, type='alnum') ->
	text = ""
	sets = {alnum: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"}
	for i in [1..len]
		text += sets[type].charAt(Math.floor(Math.random() * sets[type].length))
	return text

exports.generate_url = (type='domain') ->
	url = 'http://www.' + exports.generate_string(8) + '.com'
	switch type
		when 'png', 'jpg', 'jpeg', 'gif'
			url += '/' + exports.generate_string() + '.' + type
		when 'img'
			url += '/' + exports.generate_string() + '.png'
	return url

exports.get_url = (url, cb) ->
	http = require 'http'
	config = require('../config').config
	options = {
		host: config.server.host
		port: config.server.port
		path: url
	}
	http.get options, (res) ->
		data = ''

		res.on 'data', (chunk) ->
			data += chunk

		res.on 'end', () ->
			# console.log data
			cb res.statusCode, data

exports.get_json = (url, cb) ->
	http = require 'http'
	config = require('../config').config
	options = {
		host: config.server.host
		port: config.server.port
		path: url
	}
	http.get options, (res) ->
		data = ''

		res.on 'data', (chunk) ->
			data += chunk

		res.on 'end', () ->
			# console.log data
			obj = JSON.parse data
			# console.log obj
			cb res.statusCode, obj

exports.post_json = (url, params, cb) ->

	http = require 'http'
	urlencode = require 'urlencode'

	config = require('../config').config
	post_data = JSON.stringify(params)
	options = {
		host: config.server.host
		port: config.server.port
		path: url
		method: 'POST',
		headers:
			'Content-Type': 'application/json'
			'Content-Length': post_data.length
	}
	logger.log options
	req = http.request options, (res) ->
		data = ''
		# console.log data

		res.on 'data', (chunk) ->
			data += chunk;

		res.on 'end', () ->
			# console.log data
			obj = JSON.parse data
			cb res.statusCode, obj

	req.write post_data
	req.end()

exports.App_Runner = class App_Runner
	start: (cb, env={}) ->
		spawn = require('child_process').spawn
		opts = { cwd: undefined, env: process.env}
		for k,v of env
			opts.env[k] = v
		logger.log opts
		@server_proc  = spawn 'coffee', ['./server.coffee'], opts
		called_back = false
		@server_proc.stdout.on 'data', (data) ->
			logger.log 'stdout: ' + data
			if not called_back
				called_back = true
				cb()

		@server_proc.stderr.on 'data', (data) ->
			logger.log 'stderr: ' + data

	stop: (cb) ->
		logger.log "stopping"
		@server_proc.on 'exit', (code) ->
			# assert.equal 143, code
			logger.log 'child process exited with code ' + code
			cb()

		@server_proc.kill()
