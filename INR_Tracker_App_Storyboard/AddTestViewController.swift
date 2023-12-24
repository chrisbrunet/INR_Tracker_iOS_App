//
//  AddTestViewController.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-23.
//

import UIKit

class AddTestViewController: UIViewController {
    
    var test: Test?
    var update = false
    
    @IBOutlet weak var dateField: UIDatePicker!
    
    @IBOutlet weak var readingField: UITextField!
    
    @IBOutlet weak var notesField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet var deleteButton: UIBarButtonItem!
    
    @IBAction func saveClick(_ sender: Any) {
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        let dateString = dateFormatter.string(from: dateField.date)
        
        if update == true{
            APIFunctions.functions.updateTest(id: test!._id, date: dateString, reading: readingField.text!, notes: notesField.text!)
            print("Test updated")
        } else {
            APIFunctions.functions.createTest(date: dateString, reading: readingField.text!, notes: notesField.text!)
            print("Test created")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func deleteClick(_ sender: Any) {
        APIFunctions.functions.deleteTest(id: test!._id)
        print("Test deleted")
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if update == false {
            self.deleteButton.isEnabled = false
            self.deleteButton.title = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("controller connected")
                
        if update == true{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let dateString = test?.date,
               let date = dateFormatter.date(from: dateString) {
                dateField.date = date
            }
            readingField.text = test!.reading
            notesField.text = test?.notes
        }
       
    }
}