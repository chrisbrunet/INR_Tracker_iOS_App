//
//  APIFunctions.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-21.
//

import Foundation
import Alamofire

// defining stuct for raw data transfer between server and app
struct Test: Codable, Comparable, Identifiable {
    var _id: String
    var date: String
    var reading: String
    var notes: String
    
    var id: String {return date}
    
    // overriding comparison operators to sort entries
    static func < (lhs: Test, rhs: Test) -> Bool {
            return lhs.date < rhs.date
        }

    static func == (lhs: Test, rhs: Test) -> Bool {
        return lhs.date == rhs.date
    }
}

class APIFunctions{
    
    // specify constants for both local and cloud servers
    let ip = "localhost"
    let port = "8081"
    let url = "https://inr-app-409117.uc.r.appspot.com/"
    
    // manually select server type (use local = true for testing)
    let local = false
    
    // defining delegate property that can hold a reference to any object conforming to the DataDelegate protocol
    // will be used to reference ViewController where it sets itself as the delegate
    var delegate: DataDelegate?
    
    // allows for instantiating object of APIFunctions in other classes
    static let functions = APIFunctions()
    
    // accesses "/fetch" endpoint
    func fetchTests(){
        print("Fetching INR Tests...")
        var urlBody = ""
        if local {
            urlBody = "http://" + ip + ":" + port + "/fetch"
        } else {
            urlBody = url + "/fetch"
        }
        AF.request(urlBody).response { response in
            let data = String(data: response.data!, encoding: .utf8)
            // triggers the updateArray method in any class that conforms to the DataDelegate protocol
            self.delegate?.updateArray(newArray: data!)
        }
    }
    
    // accesses "/create" endpoint with parameters for new entry
    func createTest(date: String, reading: String, notes: String) {
        var urlBody = ""
        if local {
            urlBody = "http://" + ip + ":" + port + "/create"
        } else {
            urlBody = url + "/create"
        }
        let parameters: [String: String] = [
            "date": date,
            "reading": reading,
            "notes": notes
        ]
        
        AF.request(urlBody,
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: nil
        ).response { response in
            print(parameters)
            print("Result:")
            print(response.result)
            print("")
        }
    }
    
    // accesses "/update" endpoint with parameters for updated entry
    func updateTest(id: String, date: String, reading: String, notes: String) {
        var urlBody = ""
        if local {
            urlBody = "http://" + ip + ":" + port + "/update"
        } else {
            urlBody = url + "/update"
        }
        let parameters: [String: String] = [
            "id": id,
            "date": date,
            "reading": reading,
            "notes": notes
        ]

        AF.request(urlBody,
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: nil
        ).response { response in
            print(parameters)
            print("Result:")
            print(response.result)
            print("")
        }
    }
    
    // accesses "/delete" endpoint with parameters for removed entry
    func deleteTest(id:String) {
        var urlBody = ""
        if local {
            urlBody = "http://" + ip + ":" + port + "/delete"
        } else {
            urlBody = url + "/delete"
        }
        let parameters: [String: String] = [
            "id": id
        ]

        AF.request(urlBody,
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: nil
        ).response { response in
            print(response.result)
            print("")
        }
    }
}
