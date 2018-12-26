//
//  NetworkEncodingType.swift
//  MiniNe
//
//  Created by Kirby on 12/26/18.
//

import Foundation

public enum NetworkEncodingType {
    case json
}

extension NetworkEncodingType {
    var contentTypeValue: String {
        switch self {
        case .json:
            return "application/json"
        }
    }
}
