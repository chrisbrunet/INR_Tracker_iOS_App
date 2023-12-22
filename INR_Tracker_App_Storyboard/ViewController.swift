//
//  ViewController.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-21.
//

import UIKit

protocol DataDelegate {
    func updateArray(newArray: String)
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var inrArray = [Test]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inrArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell", for: indexPath)
        
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
        
        let inr = inrArray[indexPath.row].reading
        
        cell.textLabel?.text = formattedDate + " - INR: " + inr
        return cell
    }
    

    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APIFunctions.functions.delegate = self
        APIFunctions.functions.fetchTests()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
}

extension ViewController: DataDelegate {
    func updateArray(newArray: String){
        do {
            inrArray = try JSONDecoder().decode([Test].self, from: newArray.data(using: .utf8)!)
            print(inrArray)
        } catch {
            print("Failed to decode")
        }
        self.mainTableView?.reloadData()
    }
}

