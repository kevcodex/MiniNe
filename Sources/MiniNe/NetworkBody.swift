//
//  NetworkBody.swift
//  MiniNe
//
//  Created by Kirby on 12/26/18.
//

import Foundation

public struct NetworkBody {
    
    public let data: Data
    
    public let encoding: NetworkEncodingType
    
    public init(data: Data, encoding: NetworkEncodingType) {
        self.data = data
        self.encoding = encoding
    }
    
    public init(dictionary: [String: Any], encoding: NetworkEncodingType) throws {
        
        var data: Data
        
        switch encoding {
        case .json:
            data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        }
        
        self.init(data: data, encoding: encoding)
    }
}
