//
//  ProgressHandler.swift
//  
//
//  Created by Kevin Chen on 9/28/19.
//

import Foundation

public struct ProgressHandler {
    public let progressBlock: ((ProgressResponse) -> Void)
    public let callbackQueue: DispatchQueue
    
    public init(callbackQueue: DispatchQueue = .main,
                progressBlock: @escaping ((ProgressResponse) -> Void)) {
        self.callbackQueue = callbackQueue
        self.progressBlock = progressBlock
    }
}
