//
//  TaskHandler.swift
//  
//
//  Created by Kevin Chen on 9/28/19.
//

import Foundation

open class TaskHandler {
    public var totalBytesRecieved: Int64 = 0
    
    public var progress: Progress
            
    public var data: Data
    
    public let progressHandler: ProgressHandler?

    public let taskResponder: TaskResponder
    
    public init(taskResponder: TaskResponder, progressHandler: ProgressHandler? = nil) {
        data = Data()
        progress = Progress(totalUnitCount: 0)
        
        self.progressHandler = progressHandler
        self.taskResponder = taskResponder
    }
}
