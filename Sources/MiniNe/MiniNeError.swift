//
//  MiniNeError.swift
//  MiniNe
//
//  Created by Kirby on 9/16/18.
//

import Foundation

public enum MiniNeError: Error {
    
    case badRequest(message: String)
    
    case connectionError(Error)
    
    case responseParseError(Error)
    
    case unknown
}
