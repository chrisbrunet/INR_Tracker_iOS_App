//
//  ViewController.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-21.
//

import UIKit

// defining DataDelegate protocol with required methods
protocol DataDelegate {
    func updateArray(newArray: String)
}

// initial app view with table of INR tests
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // instantiating array of Test types
    var inrArray = [Test]()
    
    // declaring outlet for the table from storyboard
    @IBOutlet weak var mainTableView: UITableView!
    
    // using segues to send data from main view to other views in app
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // sending the Test selected in the table to the Add Test view
        if segue.identifier == "viewTestSegue" {
            if let vc = segue.destination as? AddTestViewController {
                vc.test = inrArray[mainTableView.indexPathForSelectedRow!.row]
                vc.update = true // letting the view know that we are updating a test and not creating a new one
            }
        }
        // sending the entire array of tests to the Chart view
        if segue.identifier == "viewChartSegue" {
            if let vc = segue.destination as? ChartViewController {
                vc.data = inrArray
            }
        }
    }
    
    // setting number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inrArray.count
    }
    
    // populating each cell in table with data from each Test in inrArray
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell", for: indexPath) as! TestPrototypeCell
        
        // formatting date to print in cell
        var formattedDate = ""
        let dateString = inrArray[indexPath.row].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM. dd, yyyy"
            formattedDate = dateFormatter.string(from: date)
        } else {
            print("Invalid date string")
        }
        
        // pulling INR reading to print in cell
        let inr = inrArray[indexPath.row].reading
        
        // setting label text in cell
        cell.date?.text = formattedDate
        cell.reading?.text = inr
        return cell
    }
        
    // calling fetchTests each time this view appears
    override func viewDidAppear(_ animated: Bool) {
        APIFunctions.functions.fetchTests()
    }
    
    // initializing view
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting ViewController as the delegate for APIFunctions
        APIFunctions.functions.delegate = self
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
}

// conforming to the DataDelegate protocol by implementing the updateArray method
extension ViewController: DataDelegate {
    // decodes JSON data into Test object from fetchTests API call, sorts entries by date (desc)
    func updateArray(newArray: String){
        do {
            inrArray = try JSONDecoder().decode([Test].self, from: newArray.data(using: .utf8)!)
            print("Data decoded - " + String(inrArray.count) + " entries")
            inrArray.sort(by: { $0.date > $1.date })
        } catch {
            print("Failed to decode")
        }
        self.mainTableView?.reloadData()
    }
}

