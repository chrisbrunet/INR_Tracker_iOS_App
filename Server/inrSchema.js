var mongoose = require("mongoose")
var Schema = mongoose.Schema

var test = new Schema({
    date: Date,
    reading: String,
    notes: String
})

const Data = mongoose.model("data", test)
module.exports = Data