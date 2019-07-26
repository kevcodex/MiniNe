//
//  ResponseObject.swift
//  
//
//  Created by Kevin Chen on 7/24/19.
//

import Foundation

/// A response with a already decoded object.
public class ResponseObject<Object>: Response {
    public let object: Object
    
    public init(object: Object, statusCode: Int, data: Data, request: URLRequest?, httpResponse: HTTPURLResponse?) {
        self.object = object
        super.init(statusCode: statusCode, data: data, request: request, httpResponse: httpResponse)
    }
}
