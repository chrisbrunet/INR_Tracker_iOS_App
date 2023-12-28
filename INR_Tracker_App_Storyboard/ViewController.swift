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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewTestSegue" {
            if let vc = segue.destination as? AddTestViewController {
                vc.test = inrArray[mainTableView.indexPathForSelectedRow!.row]
                vc.update = true
            }
        }
        if segue.identifier == "viewChartSegue" {
            if let vc = segue.destination as? ChartViewController {
                vc.data = inrArray
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inrArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell", for: indexPath) as! TestPrototypeCell
        
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
        
        cell.date?.text = formattedDate
        cell.reading?.text = inr
        return cell
    }
    

    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        APIFunctions.functions.fetchTests()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APIFunctions.functions.delegate = self
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
}

extension ViewController: DataDelegate {
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

