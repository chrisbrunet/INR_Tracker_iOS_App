//
//  APIFunctions.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-21.
//

import Foundation
import Alamofire

struct Test: Decodable {
    var _id: String
    var date: String
    var reading: String
    var notes: String
}

class APIFunctions{
    
    let ip = "localhost"
    let port = "8081"
    
    var delegate: DataDelegate?
    static let functions = APIFunctions()
    
    func fetchTests(){
        let urlBody = "http://" + ip + ":" + port + "/fetch"
        AF.request(urlBody).response { response in
            let data = String(data: response.data!, encoding: .utf8)
            self.delegate?.updateArray(newArray: data!)
        }
    }
    
    func createTest(date: String, reading: String, notes: String) {
        let urlBody = "http://" + ip + ":" + port + "/create"
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
            print(response.result)
        }
    }
    
    func updateTest(id:String, date: String, reading: String, notes: String) {
        let urlBody = "http://" + ip + ":" + port + "/update"
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
        let urlBody = "http://" + ip + ":" + port + "/delete"
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
