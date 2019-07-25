//
//  NetworkRequest.swift
//  SampleProject
//
//  Created by Kirby on 6/19/17.
//  Copyright © 2017 Kirby. All rights reserved.

import Foundation

public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
    
    var name: String {
        return rawValue.uppercased()
    }
}

public protocol NetworkRequest {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: Any]? { get }
    var body: NetworkBody? { get }
    var acceptableStatusCodes: [Int] { get }
}

public extension NetworkRequest {
    
    func buildURLRequest() -> URLRequest? {
        
        guard let baseURL = baseURL else {
            return nil
        }
        
        var urlRequest = URLRequest(url: baseURL)
        
        addPath(path, to: &urlRequest)
        
        addMethod(method, to: &urlRequest)
        
        addQueryParameters(parameters, to: &urlRequest)
        
        addHeaders(headers, to: &urlRequest)
        
        addRequestBody(body, to: &urlRequest)
        
        return urlRequest
    }
    
    var acceptableStatusCodes: [Int] {
        return Array(200..<300)
    }
}

// MARK: - Private Helpers
private extension NetworkRequest {
    func addPath(_ path: String, to request: inout URLRequest) {
        guard !path.isEmpty else {
            return
        }
        
        let url = request.url?.appendingPathComponent(path)
        request.url = url
    }
    
    func addMethod(_ method: HTTPMethod, to request: inout URLRequest) {
        request.httpMethod = method.name
    }
    
    func addQueryParameters(_ parameters: [String: Any]?, to request: inout URLRequest) {
        guard let parameters = parameters,
            let url = request.url else {
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        components?.queryItems = queryItems
        
        request.url = components?.url
    }
    
    func addHeaders(_ headers: [String: Any]?, to request: inout URLRequest) {
        guard let headers = headers else {
            return
        }
        
        headers.forEach { request.setValue(String(describing: $0.value), forHTTPHeaderField: $0.key) }
    }
    
    func addRequestBody(_ body: NetworkBody?, to request: inout URLRequest) {
        guard let body = body else {
            return
        }
        
        switch body.encoding {
            
        case .json:
            request.setValue(body.encoding.contentTypeValue, forHTTPHeaderField: "Content-Type")
            request.httpBody = body.data
        }
    }
}

public protocol CodableRequest: NetworkRequest {
    associatedtype Response: Codable
}

public protocol JSONRequest: NetworkRequest {
    associatedtype Response: JSONDecodable
}
