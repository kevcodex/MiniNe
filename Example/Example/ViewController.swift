//
//  ViewController.swift
//  Example
//
//  Created by Kevin Chen on 7/24/19.
//  Copyright © 2019 Kevin Chen. All rights reserved.
//

import UIKit
import MiniNe

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = TestRequest()
        
        let client = MiniNeClient()
        
        client.send(request: request, progressBlock: { (progress) in
            print(progress)
        }) { (result) in
            switch result {
            case .success(let response):
                let jsonDecoder = JSONDecoder()
                do {
                    let model = try jsonDecoder.decode(TestCodableModel.self, from: response.data)
                    print("Simple Request: \n Code: \(response.statusCode), \(model)")
                } catch {
                    print(error)
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        client.send(responseType: TestCodableModel.self, request: request) { (result) in
            switch result {
            case .success(let response):
                print("Auto Decode Codable Request: \n Code: \(response.statusCode), \(response.object)")
                
            case .failure(let error):
                print(error)
            }
        }
        
        client.send(responseType: TestJSONModel.self, request: request) { (result) in
            switch result {
                
            case .success(let response):
                print("Auto Decode JSON Decodable Request: \n Code: \(response.statusCode), \(response.object)")
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct TestCodableModel: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

enum JSONDecodeError: Error {
  case invalidFormat
  case missingValue(key: String, actualValue: Any?)
}

struct TestJSONModel: JSONDecodable {
    
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
    
    init(json: Any) throws {
        guard let dictionary = json as? [String: Any] else {
            throw JSONDecodeError.invalidFormat
        }
        
        guard let userId = dictionary["userId"] as? Int else {
            throw JSONDecodeError.missingValue(key: "userId", actualValue: dictionary["userId"])
        }
        
        guard let id = dictionary["id"] as? Int else {
            throw JSONDecodeError.missingValue(key: "id", actualValue: dictionary["id"])
        }
        
        guard let title = dictionary["title"] as? String else {
            throw JSONDecodeError.missingValue(key: "title", actualValue: dictionary["title"])
        }
        guard let completed = dictionary["completed"] as? Bool else {
            throw JSONDecodeError.missingValue(key: "completed", actualValue: dictionary["completed"])
        }
        
        self.userId = userId
        self.id = id
        self.title = title
        self.completed = completed
    }
}

struct TestRequest: NetworkRequest {
    var baseURL: URL? {
        URL(string: "https://jsonplaceholder.typicode.com")
    }
    
    var path: String {
        "/todos/1"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: [String : Any]?
    
    var headers: [String : Any]?
    
    var body: NetworkBody?
}
