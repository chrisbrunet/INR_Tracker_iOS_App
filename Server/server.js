const express = require("express")
const mongoose = require("mongoose")
const bodyParser = require('body-parser')
var app = express()
var Data = require("./inrSchema")

mongoose.connect("mongodb://localhost/inrDB")
mongoose.connection.once("open", () => {
    console.log("Connected to DB")
}).on("error", (error) => {
    console.log("Failed to Connect to DB: " + error)
})

app.use(bodyParser.json())

// Create a test
// http://192.168.1.71:8081/create
app.post("/create", (req, res) => {

    console.log("PRINTING REQUEST BODY")
    console.log(req.body)

    const date = new Date(req.body.date)
    const reading = req.body.reading
    const notes = req.body.notes

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
// http://192.168.1.71:8081/fetch
app.get("/fetch", (req, res) => {
    Data.find({}).then((DBItems) => {
        console.log("All Data Fetched")
        res.send(DBItems)
    })
})

// Update a test
// http://192.168.1.71:8081/update
app.post("/update", (req, res) => {

    console.log("PRINTING REQUEST BODY")
    console.log(req.body)

    const id = req.body.id
    const date = new Date(req.body.date)
    const reading = req.body.reading
    const notes = req.body.notes

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
// http://192.168.1.71:8081/delete
app.post("/delete", (req, res) => {

    console.log("PRINTING REQUEST BODY")
    console.log(req.body)

    const id = req.body.id

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

var server = app.listen(8081, "192.168.1.71", () => {
    console.log("Server is running")
})