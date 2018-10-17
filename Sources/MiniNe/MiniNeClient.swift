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
    
    public func send<Request: NetworkRequest>(request: Request,
                                              completion: @escaping (Result<Response, MiniNeError>) -> Void) {
        
        guard let urlRequest = request.buildURLRequest() else {
            completion(Result(error: .badRequest(message: "Bad URL Request")))
            return
        }
        
        let task = session.dataTask(with: urlRequest) {
            data, response, error in
            
            switch (data, response, error) {
                
            // if an error
            case let (_, _, error?):
                completion(Result(error: .connectionError(error)))
                
            // if theres data and response
            case let (data?, response?, _):
                
                guard let urlResponse = response as? HTTPURLResponse else {
                    completion(Result(error: .badRequest(message: "Bad HTTPURL Request")))
                    return
                }
                
                let response = request.response(from: data, urlResponse: urlResponse)
                completion(Result(value: response))
                
            default:
                assertionFailure("Invalid response combination")
                completion(Result(error: .unknown))
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
