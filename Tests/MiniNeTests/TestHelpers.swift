//
//  TestHelpers.swift
//  
//
//  Created by Kevin Chen on 7/26/19.
//

import Foundation
import MiniNe

class MockURLSession: URLSession {
    var mockData: Data?
    var mockURLResponse: URLResponse?
    var mockError: Error?
    
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
