//
//  NetworkBody.swift
//  MiniNe
//
//  Created by Kirby on 12/26/18.
//

import Foundation

public struct NetworkBody {
    
    public let parameters: [String: Any]
    
    public let encoding: NetworkEncodingType
    
    public init(parameters: [String: Any], encoding: NetworkEncodingType) {
        self.parameters = parameters
        self.encoding = encoding
    }
}
