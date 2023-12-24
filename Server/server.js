const express = require("express")
const mongoose = require("mongoose")
const bodyParser = require('body-parser')
var app = express()
var Data = require("./inrSchema")
const config = require('./config')

const username = config.username
const password = config.password

mongoose.connect(`mongodb+srv://${username}:${password}@cbcluster.nygn6bq.mongodb.net/inrDB`)
mongoose.connection.once("open", () => {
    console.log("Connected to DB")
}).on("error", (error) => {
    console.log("Failed to Connect to DB: " + error)
})

app.use(bodyParser.json())

// Create a test
app.post("/create", (req, res) => {

    let date, reading, notes

    if(req.body.date && req.body.reading){
        console.log("PRINTING REQUEST BODY")
        console.log(req.body)

        date = parseCustomDate(req.body.date)
        reading = req.body.reading
        notes = req.body.notes
    } else {
        console.log("PRINTING REQUEST QUERY")
        console.log(req.query)

        date = parseCustomDate(req.query.date)
        reading = req.query.reading
        notes = req.query.notes
    }

    var newTest = new Data({
        date: date,
        reading: reading,
        notes: notes
    })

    newTest.save().then(() => {
        if (newTest.isNew == false){
            console.log("Saved new INR test")
            res.send("Saved new INR test")
        } else {
            console.log("Failed to Save Data")
        }
    })
})

// Read all tests
app.get("/fetch", (req, res) => {
    Data.find({}).then((DBItems) => {
        console.log("All Data Fetched")
        res.send(DBItems)
    })
})

// Update a test
app.post("/update", (req, res) => {

    let id, date, reading, notes

    if(req.body.date && req.body.reading){
        console.log("PRINTING REQUEST BODY")
        console.log(req.body)

        id = req.body.id
        date = parseCustomDate(req.body.date)
        reading = req.body.reading
        notes = req.body.notes
    } else {
        console.log("PRINTING REQUEST QUERY")
        console.log(req.query)

        id = req.query.id
        date = parseCustomDate(req.query.date)
        reading = req.query.reading
        notes = req.query.notes
    }

    Data.findOneAndUpdate({
        _id: id
    }, {
        date: date,
        reading: reading,
        notes: notes
    }).then((updatedItem) => {
        if (updatedItem) {
            console.log("Entry " + id + " updated")
            res.send("Entry " + id + " updated")
        } else {
            console.log("Entry " + id + " does not exist")
            res.send("Entry " + id + " does not exist")
        }
    })
})

// Delete a test
app.post("/delete", (req, res) => {

    let id

    if(req.body.id){
        console.log("PRINTING REQUEST BODY")
        console.log(req.body)

        id = req.body.id
    } else {
        console.log("PRINTING REQUEST QUERY")
        console.log(req.query)

        id = req.query.id
    }

    Data.findOneAndDelete({
        _id: id
    }).then((deletedItem) => {
        if (deletedItem) {
            console.log("Entry " + id + " deleted")
            res.send("Entry " + id + " deleted")
        } else {
            console.log("Entry " + id + " does not exist or already deleted")
            res.send("Entry " + id + " does not exist or already deleted")
        }
    })
})

var server = app.listen(8081, "localhost", () => {
    console.log("Server is running")
})

function parseCustomDate(dateString) {
    const parts = dateString.split(' ')
    const dateParts = parts[0].split('-')
    const timeParts = parts[1].split(':')

    const year = parseInt(dateParts[0]);
    const month = parseInt(dateParts[1]) - 1
    const day = parseInt(dateParts[2])

    const hour = parseInt(timeParts[0])
    const minute = parseInt(timeParts[1])
    const second = parseInt(timeParts[2])

    return new Date(year, month, day, hour, minute, second);
}