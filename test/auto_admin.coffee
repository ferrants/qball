assert = require 'assert'
generate_string = require('./helpers').generate_string
post_json = require('./helpers').post_json
get_json = require('./helpers').get_json
App_Runner = require('./helpers').App_Runner
ae = assert.equal
			
describe 'auto_admin | ', () ->

	before (cb) ->
		@server = new App_Runner
		@server.start cb, {'CHECK_INTERVAL': 50}

	beforeEach (cb) ->
		@ball = generate_string(8)
		cb()

	after (cb) ->
		@server.stop () ->
			cb()

	it 'defaults to false', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			ae data.auto_admin, false
			cb()

	it 'can be enabled', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			ae data.auto_admin, false
			get_json "/dude/put/#{ball}", (status, data) ->
				ae data.holder, false
				ae data.ball_name, ball
				ae data.auto_admin, false
				get_json "/balls/#{ball}/auto_admin", (status, data) ->
					ae data.holder, false
					ae data.ball_name, ball
					ae data.auto_admin, true
					cb()

	it 'can kick a holder', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			ae data.auto_admin, false
			get_json "/dude/put/#{ball}", (status, data) ->
				ae data.holder, false
				ae data.ball_name, ball
				ae data.auto_admin, false
				get_json "/balls/#{ball}/auto_admin", (status, data) ->
					ae data.holder, false
					ae data.ball_name, ball
					ae data.auto_admin, true
					get_json "/balls/#{ball}/auto_admin_holder_limit/100", (status, data) ->
						ae data.holder, false
						ae data.ball_name, ball
						ae data.auto_admin, true
						ae data.auto_admin_holder_limit, 100
						get_json "/dude/hold/#{ball}", (status, data) ->
							ae data.holder, 'dude'
							ae data.ball_name, ball
							ae data.auto_admin, true
							ae data.auto_admin_holder_limit, 100
							next = () ->
								get_json "/balls/#{ball}", (status, data) ->
									ae data.holder, false
									ae data.ball_name, ball
									ae data.auto_admin, true
									ae data.auto_admin_holder_limit, 100
									cb()
							setTimeout next, 200

	it 'can rotate the queue', (cb) ->
		ball = @ball
		get_json "/dude/hold/#{ball}", (status, data) ->
			ae data.holder, 'dude'
			ae data.ball_name, ball
			ae data.auto_admin, false
			get_json "/balls/#{ball}/auto_admin", (status, data) ->
				ae data.holder, 'dude'
				ae data.ball_name, ball
				ae data.auto_admin, true
				get_json "/balls/#{ball}/auto_admin_queue_lead_limit/100", (status, data) ->
					ae data.holder, 'dude'
					ae data.ball_name, ball
					ae data.auto_admin, true
					ae data.auto_admin_queue_lead_limit, 100
					get_json "/bro/wait_for/#{ball}", (status, data) ->
						ae data.holder, 'dude'
						ae data.ball_name, ball
						ae data.auto_admin, true
						ae data.list[0], 'bro'
						get_json "/guy/wait_for/#{ball}", (status, data) ->
							ae data.holder, 'dude'
							ae data.ball_name, ball
							ae data.auto_admin, true
							ae data.list[0], 'bro'
							ae data.list[1], 'guy'
							next = () ->
								get_json "/balls/#{ball}", (status, data) ->
									ae data.holder, 'dude'
									ae data.ball_name, ball
									ae data.auto_admin, true
									ae data.list[0], 'bro'
									ae data.list[1], 'guy'
									get_json "/dude/put/#{ball}", (status, data) ->
										ae data.holder, false
										ae data.ball_name, ball
										ae data.auto_admin, true
										ae data.list[0], 'bro'
										ae data.list[1], 'guy'
										next2 = () ->
											get_json "/balls/#{ball}", (status, data) ->
												ae data.holder, false
												ae data.ball_name, ball
												ae data.auto_admin, true
												ae data.list[0], 'guy'
												ae data.list[1], 'bro'
												cb()
										setTimeout next2, 150
							setTimeout next, 200
			
			
