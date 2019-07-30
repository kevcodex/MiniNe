//
//  MiniNeError.swift
//  MiniNe
//
//  Created by Kirby on 9/16/18.
//

import Foundation

public enum MiniNeError: Error {
    
    case badRequest(message: String)
    
    case responseValidationFailed(Response)
    
    case connectionError(Error)
    
    case responseParseError(Error, response: Response)
    
    case unknown
    
    public var response: Response? {
        switch self {
            
        case .badRequest:
            return nil
        case .responseValidationFailed(let response):
            return response
        case .connectionError:
            return nil
        case .responseParseError(_, let response):
            return response
        case .unknown:
            return nil
        }
    }
}
