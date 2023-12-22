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
    
    var delegate: DataDelegate?
    static let functions = APIFunctions()
    
    func fetchTests(){
        AF.request("http://192.168.1.71:8081/fetch").response { response in
            let data = String(data: response.data!, encoding: .utf8)
            self.delegate?.updateArray(newArray: data!)
        }
    }
}
