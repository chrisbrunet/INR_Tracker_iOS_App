//
//  APIFunctions.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-21.
//

import Foundation
import Alamofire

struct Test: Codable, Comparable, Identifiable {
    var _id: String
    var date: String
    var reading: String
    var notes: String
    
    var id: String {return date}
    
    static func < (lhs: Test, rhs: Test) -> Bool {
            return lhs.date < rhs.date
        }

    static func == (lhs: Test, rhs: Test) -> Bool {
        return lhs.date == rhs.date
    }
}

class APIFunctions{
    
    let ip = "localhost"
    let port = "8081"
    let url = "https://inr-app-409117.uc.r.appspot.com/"
    
    let local = false
    
    var delegate: DataDelegate?
    static let functions = APIFunctions()
    
    func fetchTests(){
        var urlBody = ""
        if local {
            urlBody = "http://" + ip + ":" + port + "/fetch"
        } else {
            urlBody = url + "/fetch"
        }
        AF.request(urlBody).response { response in
            let data = String(data: response.data!, encoding: .utf8)
            self.delegate?.updateArray(newArray: data!)
            print("INR Tests Fetched")
        }
    }
    
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
        
        print(parameters)

        AF.request(urlBody,
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: nil
        ).response { response in
            print(response.result)
        }
    }
    
    func updateTest(id:String, date: String, reading: String, notes: String) {
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
            print(response.result)
        }
    }
    
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
        }
    }
}
