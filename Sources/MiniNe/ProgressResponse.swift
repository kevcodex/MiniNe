//
//  ProgressResponse.swift
//  
//
//  Created by Kevin Chen on 9/22/19.
//

import Foundation

public struct ProgressResponse {

    public let progress: Progress

    public init(progress: Progress) {
        self.progress = progress
    }
    
    public var isCompleted: Bool {
        return progress.fractionCompleted == 1.0
    }
}
