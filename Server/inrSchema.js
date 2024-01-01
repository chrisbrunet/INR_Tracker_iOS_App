// Defining a fixed schema for our database and exporting as "Data"
var mongoose = require("mongoose")
var Schema = mongoose.Schema

var test = new Schema({
    date: Date,
    reading: String,
    notes: String
})

const Data = mongoose.model("data", test)
module.exports = Data