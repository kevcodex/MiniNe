//
//  MiniNeError.swift
//  MiniNe
//
//  Created by Kirby on 9/16/18.
//

import Foundation

public enum MiniNeError: Error {
    
    case badRequest(message: String)
    
    case responseValidationFailed(ResponseValidationFailure)
    
    case connectionError(Error)
    
    case responseParseError(Error)
    
    case unknown
}

public enum ResponseValidationFailure: Error {
    case invalidStatusCode(code: Int)
}
