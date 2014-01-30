mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/compete'

competition_schema = mongoose.Schema { 
	name: Object
}

exports.Competition = mongoose.model 'Competition', competition_schema
