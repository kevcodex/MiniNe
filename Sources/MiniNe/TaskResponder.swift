//
//  File.swift
//  
//
//  Created by Kevin Chen on 9/28/19.
//

import Foundation

public protocol TaskResponder {
    var didComplete: ((Data?, URLResponse?, Error?) -> Void) { get set }
}

public struct DataTaskResponder: TaskResponder {
    public var didComplete: ((Data?, URLResponse?, Error?) -> Void)
    
    init(completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        self.didComplete = completion
    }
}
