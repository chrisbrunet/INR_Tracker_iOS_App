//
//  AddTestViewController.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-23.
//

import UIKit

class AddTestViewController: UIViewController {
    
    // instantiating test variable as a Test object and update as false initially
    var test: Test?
    var update = false
    
    // declaring outlet for all of the fields and buttons in the Storyboard UI view
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet weak var readingField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    
    // function to be called when the save button is clicked
    @IBAction func saveClick(_ sender: Any) {
        
        // formatting date from the date picker into a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        let dateString = dateFormatter.string(from: dateField.date)
        
        // call either updateTest or createTest depending on value of "update" passed from segue
        if update == true{
            print("Test Updated:")
            APIFunctions.functions.updateTest(id: test!._id, date: dateString, reading: readingField.text!, notes: notesField.text!)
        } else {
            print("Test Created:")
            APIFunctions.functions.createTest(date: dateString, reading: readingField.text!, notes: notesField.text!)
        }
        // return to the main view of the app
        self.navigationController?.popViewController(animated: true)
    }
    
    // function to be called when the delete button is clicked
    @IBAction func deleteClick(_ sender: Any) {
        // calls deleteTest function and returns to main view of app
        APIFunctions.functions.deleteTest(id: test!._id)
        print("Test Deleted\nResult:")
        self.navigationController?.popViewController(animated: true)
    }
    
    // modifying how the view will load based on if the we are updating or creating a new test
    override func viewWillAppear(_ animated: Bool) {
        // if we are creating a new test, disable and remove the delete button
        if update == false {
            self.deleteButton.isEnabled = false
            self.deleteButton.title = ""
        // if we are updating a test, rename the page to "Update Test"
        } else {
            self.navBar.title = "Update Test"
        }
    }

    // Populating fields in view based on if we are updating or creating a new test
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Test Controller Connected")
        
        // if we are updating a test, format date from Test object to Date type, then populate all fields
        if update == true {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.timeZone = TimeZone(identifier: "America/Denver")
            
            if let dateString = test?.date,
               let date = dateFormatter.date(from: dateString) {
                let updatedDate = date.addingTimeInterval(7 * 3600) // manually adding 7 hours to the date because this is so painful
                dateField.timeZone = TimeZone(identifier: "America/Denver")
                dateField.setDate(updatedDate, animated: true)
            }
            readingField.text = test!.reading
            notesField.text = test?.notes
        }
        
        // if it is a new test, all fields will be blank with Date field automatically set to current
    }
}
