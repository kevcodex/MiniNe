//
//  MiniNeClient.swift
//  MiniNe
//
//  Created by Kirby on 9/16/18.
//

import Foundation

public class MiniNeClient {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    /// Basic network request to return data.
    public func send<Request: NetworkRequest>(request: Request,
                                              completion: @escaping (Result<Response, MiniNeError>) -> Void) {
        
        guard let urlRequest = request.buildURLRequest() else {
            completion(.failure(.badRequest(message: "Bad URL Request")))
            return
        }
        
        let task = session.dataTask(with: urlRequest) {
            data, response, error in
            
            switch (data, response, error) {
                
            // if an error
            case let (_, _, error?):
                completion(.failure(.connectionError(error)))
                
            // if theres data and response
            case let (data?, response?, _):
                
                guard let urlResponse = response as? HTTPURLResponse else {
                    completion(.failure(.badRequest(message: "Bad HTTP URL Request")))
                    return
                }
                
                let response = Response(statusCode: urlResponse.statusCode, data: data, requestURL: urlResponse.url)
                
                guard response.isValid(statusCodes: request.acceptableStatusCodes) else {
                    let failure = ResponseValidationFailure.invalidStatusCode(code: response.statusCode)
                    completion(.failure(.responseValidationFailed(failure)))
                    return
                }
                
                completion(.success(response))
                
            default:
                assertionFailure("Invalid response combination")
                completion(.failure(.unknown))
                break
            }
        }
        task.resume()
    }
    
    /// Cancels all outstanding tasks and then invalidates the URLSession.
    public func invalidateAndCancel() {
        session.invalidateAndCancel()
    }
    
    public init() { }
}

// MARK: - Codable Requests
extension MiniNeClient {
    /// Makes a network request with any codable response object and will return it.
    public func send<Request: CodableRequest>(
        codableRequest: Request,
        completion: @escaping (Result<ResponseObject<Request.Response>, MiniNeError>) -> Void) {
        
        send(request: codableRequest) { (result) in
            switch result {
            case .success(let response):
                let decoder = JSONDecoder()
                do {
                    let object = try decoder.decode(Request.Response.self, from: response.data)
                    let response = ResponseObject(object: object, statusCode: response.statusCode, data: response.data, requestURL: response.requestURL)
                    completion(.success(response))
                } catch {
                    completion(.failure(.responseParseError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Network request to decode to the specified codable object
    public func send<Request: NetworkRequest, Response: Codable>(
        responseType: Response.Type,
        request: Request,
        completion: @escaping (Result<ResponseObject<Response>, MiniNeError>) -> Void) {
        
        send(request: request) { (result) in
            switch result {
            case .success(let response):
                let decoder = JSONDecoder()
                do {
                    let object = try decoder.decode(responseType.self, from: response.data)
                    let foo = ResponseObject(object: object, statusCode: response.statusCode, data: response.data, requestURL: response.requestURL)
                    completion(.success(foo))
                } catch {
                    completion(.failure(.responseParseError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - JSONDecodable Requests
extension MiniNeClient {
    /// Send a network request and return a decoded object defined by the JSONDecodable protocol in the JSONRequest.
    public func send<Request: JSONRequest>(
        jsonRequest: Request,
        completion: @escaping (Result<ResponseObject<Request.Response>, MiniNeError>) -> Void) {
        
        send(request: jsonRequest) { (result) in
            switch result {
            case .success(let response):
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data, options: [])
                    let object = try Request.Response(json: json)
                    let response = ResponseObject(object: object, statusCode: response.statusCode, data: response.data, requestURL: response.requestURL)
                    completion(.success(response))
                } catch {
                    completion(.failure(.responseParseError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Send a network request and return a JSON decoded object specified.
    public func send<Request: NetworkRequest, Response: JSONDecodable>(
        responseType: Response.Type,
        request: Request,
        completion: @escaping (Result<ResponseObject<Response>, MiniNeError>) -> Void) {
        
        send(request: request) { (result) in
            switch result {
            case .success(let response):
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data, options: [])
                    let object = try Response(json: json)
                    let foo = ResponseObject(object: object, statusCode: response.statusCode, data: response.data, requestURL: response.requestURL)
                    completion(.success(foo))
                } catch {
                    completion(.failure(.responseParseError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

