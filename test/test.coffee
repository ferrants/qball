assert = require 'assert'
generate_string = require('./helpers').generate_string
post_json = require('./helpers').post_json
get_json = require('./helpers').get_json
App_Runner = require('./helpers').App_Runner
ae = assert.equal
			
describe 'balls | ', () ->

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

	it 'dude can hold a ball', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae 200, status
			ae data.holder, 'dude'
			ae data.ball_name, ball
			cb()

	it 'dude can return a ball', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/dude/put/#{ball}", (status, data) ->
				ae 200, status
				ae data.holder, false
				ae data.ball_name, ball
				cb()

	it 'dude can hold a ball and bro can see that', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae 200, status
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/balls/#{ball}", (status, data) ->
				ae 200, status
				ae data.holder, 'dude'
				ae data.ball_name, ball
				cb()

	it 'bro can wait for dude', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/bro/hold/#{ball}", (status, data) ->
				ae 405, status
				ae data.holder, 'dude'
				ae data.ball_name, ball
				get_json "/dude/put/#{ball}", (status, data) ->
					ae 200, status
					ae data.holder, false
					ae data.ball_name, ball
					get_json "/bro/hold/#{ball}", (status, data) ->
						ae 200, status
						ae data.holder, 'bro'
						ae data.ball_name, ball
						cb()

	it 'bro can wait in line for dude', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/bro/hold/#{ball}", (status, data) ->
				ae 405, status
				ae 'dude', data.holder
				ae ball, data.ball_name
				get_json "/bro/wait_for/#{ball}", (status, data) ->
					ae 200, status
					ae 'dude', data.holder
					ae ball, data.ball_name
					assert.equal 'bro', data.list[0]
					get_json "/dude/put/#{ball}", (status, data) ->
						ae 200, status
						ae data.holder, false
						ae data.ball_name, ball
						get_json "/bro/hold/#{ball}", (status, data) ->
							ae 200, status
							ae data.holder, 'bro'
							ae data.ball_name, ball
							cb()

	it 'guy can wait his fuckin turn in line for dude', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			get_json "/bro/hold/#{ball}", (status, data) ->
				ae 405, status
				ae 'dude', data.holder
				ae ball, data.ball_name
				get_json "/bro/wait_for/#{ball}", (status, data) ->
					ae 200, status
					ae 'dude', data.holder
					ae ball, data.ball_name
					assert.equal 'bro', data.list[0]
					get_json "/guy/hold/#{ball}", (status, data) ->
						ae 405, status
						ae 'dude', data.holder
						ae ball, data.ball_name
						get_json "/guy/wait_for/#{ball}", (status, data) ->
							ae 200, status
							ae 'dude', data.holder
							ae ball, data.ball_name
							assert.equal 'bro', data.list[0]
							assert.equal 'guy', data.list[1]
							get_json "/dude/put/#{ball}", (status, data) ->
								ae 200, status
								ae data.holder, false
								ae data.ball_name, ball
								get_json "/guy/hold/#{ball}", (status, data) ->
									ae 405, status
									ae false, data.holder
									ae ball, data.ball_name
									assert.equal 'bro', data.list[0]
									assert.equal 'guy', data.list[1]
									get_json "/bro/hold/#{ball}", (status, data) ->
										ae 200, status
										ae data.holder, 'bro'
										ae data.ball_name, ball
										get_json "/bro/put/#{ball}", (status, data) ->
											ae 200, status
											ae data.holder, false
											ae data.ball_name, ball
											get_json "/guy/hold/#{ball}", (status, data) ->
												ae 200, status
												ae data.holder, 'guy'
												ae data.ball_name, ball
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

