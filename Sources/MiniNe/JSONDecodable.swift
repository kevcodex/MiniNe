//
//  JSONDecodable.swift
//  
//
//  Created by Kevin Chen on 7/24/19.
//

import Foundation

public protocol JSONDecodable {
    init(json: Any) throws
}
