//
//  TaskHandler.swift
//  
//
//  Created by Kevin Chen on 9/28/19.
//

import Foundation

public struct TaskHandler {
    public var totalBytesRecieved: Int64 = 0
    
    public var progress: Progress
            
    public var data: Data
    
    public let progressBlock: ((ProgressResponse) -> Void)?

    public let taskResponder: TaskResponder
    
    public init(taskResponder: TaskResponder, progressBlock: ((ProgressResponse) -> Void)? = nil) {
        data = Data()
        progress = Progress(totalUnitCount: 0)
        
        self.progressBlock = progressBlock
        self.taskResponder = taskResponder
    }
}
