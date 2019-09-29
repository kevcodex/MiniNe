//
//  TestHelpers.swift
//  
//
//  Created by Kevin Chen on 7/26/19.
//

import Foundation
import MiniNe

class Tester: SessionDelegate {
    var mockData: Data?
    var mockURLResponse: URLResponse?
    var mockError: Error?
    
    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        test?(mockData, mockURLResponse, mockError)
    }
}

class MockURLSession: URLSession {
    var mockData: Data?
    var mockURLResponse: URLResponse?
    var mockError: Error?
    
    override var delegate: URLSessionDelegate? {
        return SessionDelegate()
    }
    
    override var configuration: URLSessionConfiguration {
        return .default
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        completionHandler(mockData, mockURLResponse, mockError)
        
        return URLSessionDataTask()
    }
}

enum MockStandardRequest: NetworkRequest {
    case validRequest
    case validRequestWithPath
    case invalidRequest
    case validRequestWithQueryParams
    case validRequestWithHeaders
    case validRequestWithJSONBody
    
    var baseURL: URL? {
        switch self {
            
        case .validRequest:
            return URL(string: "https://mockurl.com")
        case .validRequestWithPath:
            return URL(string: "https://mockurl.com")
        case .invalidRequest:
            return URL(string: "")
        case .validRequestWithQueryParams:
            return URL(string: "https://mockurl.com")
        case .validRequestWithHeaders:
            return URL(string: "https://mockurl.com")
        case .validRequestWithJSONBody:
            return URL(string: "https://mockurl.com")
        }
    }
    
    var path: String {
        switch self {
            
        case .validRequest:
            return ""
        case .validRequestWithPath:
            return "/foo"
        case .invalidRequest:
            return ""
        case .validRequestWithQueryParams:
            return ""
        case .validRequestWithHeaders:
            return ""
        case .validRequestWithJSONBody:
            return ""
            
        }
    }
    
    var method: HTTPMethod {
        switch self {
            
        case .validRequest:
            return .get
        case .validRequestWithPath:
            return .get
        case .invalidRequest:
            return .get
        case .validRequestWithQueryParams:
            return .get
        case .validRequestWithHeaders:
            return .get
        case .validRequestWithJSONBody:
            return .get
            
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .validRequest:
            return nil
        case .validRequestWithPath:
            return nil
        case .invalidRequest:
            return nil
        case .validRequestWithQueryParams:
            return ["foo": "bar", "fooz": "barz"]
        case .validRequestWithHeaders:
            return nil
        case .validRequestWithJSONBody:
            return nil
            
        }
    }
    
    var headers: [String : Any]? {
        switch self {
        case .validRequest:
            return nil
        case .validRequestWithPath:
            return nil
        case .invalidRequest:
            return nil
        case .validRequestWithQueryParams:
            return nil
        case .validRequestWithHeaders:
            return ["foo": "bar", "fooz": "barz"]
        case .validRequestWithJSONBody:
            return nil
            
        }
    }
    
    var body: NetworkBody? {
        switch self {
        case .validRequest:
            return nil
        case .validRequestWithPath:
            return nil
        case .invalidRequest:
            return nil
        case .validRequestWithQueryParams:
            return nil
        case .validRequestWithHeaders:
            return nil
        case .validRequestWithJSONBody:
            let data =
                """
                    {"foo": "bar"}
                """
                    .data(using: .utf8)
            
            
            return NetworkBody(data: data!, encoding: .json)
            
        }
    }
}

struct Foo: Decodable, Equatable {
    let foo: String
    let fooz: String
}

enum JSONDecodeError: Error {
    case invalidFormat
    case missingValue(key: String, actualValue: Any?)
}

struct Bar: JSONDecodable {
    
    let bar: String
    let barz: String
    
    init(json: Any) throws {
        guard let dictionary = json as? [String: Any] else {
            throw JSONDecodeError.invalidFormat
        }
        
        guard let bar = dictionary["bar"] as? String else {
            throw JSONDecodeError.missingValue(key: "bar", actualValue: dictionary["bar"])
        }
        
        guard let barz = dictionary["barz"] as? String else {
            throw JSONDecodeError.missingValue(key: "barz", actualValue: dictionary["barz"])
        }
        
        self.bar = bar
        self.barz = barz
    }
}

struct MockCodableRequest: CodableRequest {
    typealias Response = Foo
    
    var baseURL: URL? {
        return URL(string: "https://mockurl.com")
    }
    
    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any]?
    
    var headers: [String : Any]?
    
    var body: NetworkBody?
}

struct MockJSONDecodableRequest: JSONRequest {
    typealias Response = Bar
    
    var baseURL: URL? {
        return URL(string: "https://mockurl.com")
    }
    
    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any]?
    
    var headers: [String : Any]?
    
    var body: NetworkBody?
}
