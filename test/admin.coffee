assert = require 'assert'
generate_string = require('./helpers').generate_string
post_json = require('./helpers').post_json
get_json = require('./helpers').get_json
App_Runner = require('./helpers').App_Runner
ae = assert.equal
			
describe 'admin | ', () ->

	before (cb) ->
		@server = new App_Runner
		@server.start () ->
			cb()

	beforeEach (cb) ->
		@ball = generate_string(8)
		cb()

	after (cb) ->
		@server.stop () ->
			cb()

	it 'can drop a ball', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/balls/#{ball}/drop", (status, data) ->
				ae 200, status
				ae data.ball_name, ball
				get_json "/balls/#{ball}", (status, data) ->
					ae 404, status
					cb()

	it 'can clear a ball', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/bro/wait_for/#{ball}", (status, data) ->
				ae 200, status
				ae 'dude', data.holder
				ae ball, data.ball_name
				ae 'bro', data.list[0]
				get_json "/balls/#{ball}/clear", (status, data) ->
					ae 200, status
					ae data.ball_name, ball
					ae false, data.holder
					ae 0, data.list.length
					get_json "/balls/#{ball}", (status, data) ->
						ae 200, status
						ae false, data.holder
						ae 0, data.list.length
						cb()

	it 'can kick holder off a ball', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/bro/wait_for/#{ball}", (status, data) ->
				ae 200, status
				ae 'dude', data.holder
				ae ball, data.ball_name
				ae 'bro', data.list[0]
				get_json "/balls/#{ball}/kick", (status, data) ->
					ae 200, status
					ae data.ball_name, ball
					ae false, data.holder
					ae 'bro', data.list[0]
					get_json "/balls/#{ball}", (status, data) ->
						ae 200, status
						ae false, data.holder
						ae 'bro', data.list[0]
						get_json "/bro/hold/#{ball}", (status, data) ->
							ae 200, status
							ae data.holder, 'bro'
							ae data.ball_name, ball
							ae 0, data.list.length
							cb()

	it 'can rotate a ball queue', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/bro/wait_for/#{ball}", (status, data) ->
				ae 200, status
				ae 'dude', data.holder
				ae ball, data.ball_name
				ae 'bro', data.list[0]
				get_json "/guy/wait_for/#{ball}", (status, data) ->
					ae 200, status
					ae 'dude', data.holder
					ae ball, data.ball_name
					ae 'bro', data.list[0]
					ae 'guy', data.list[1]
					get_json "/balls/#{ball}/rotate", (status, data) ->
						ae 200, status
						ae data.ball_name, ball
						ae 'dude', data.holder
						ae 'guy', data.list[0]
						ae 'bro', data.list[1]
						cb()

	it 'can rotate a ball queue with 1 person', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/bro/wait_for/#{ball}", (status, data) ->
				ae 200, status
				ae 'dude', data.holder
				ae ball, data.ball_name
				ae 'bro', data.list[0]
				get_json "/balls/#{ball}/rotate", (status, data) ->
					ae 200, status
					ae 'dude', data.holder
					ae ball, data.ball_name
					ae 'bro', data.list[0]
					cb()

	it 'can rotate a ball queue with no people', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/balls/#{ball}/rotate", (status, data) ->
				ae 200, status
				ae 'dude', data.holder
				ae ball, data.ball_name
				ae 0, data.list.length
				get_json "/balls/#{ball}/rotate", (status, data) ->
					ae 200, status
					ae 'dude', data.holder
					ae ball, data.ball_name
					ae 0, data.list.length
					cb()

