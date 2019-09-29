//
//  SessionDelegate
//  
//
//  Created by Kevin Chen on 9/22/19.
//

import Foundation

open class SessionDelegate: NSObject {
    
    /// Used because multiple threads could access or modify the tasks dictionary
    private let serialQueue: DispatchQueue = DispatchQueue(label: "TaskHandlerSerialQueue")
    
    public var tasks: [Int: TaskHandler] = [:]
    
    public override init() {
        super.init()
    }
}

extension SessionDelegate: URLSessionDelegate {

    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        serialQueue.sync {
            let taskHandler = tasks[task.taskIdentifier]
            
            taskHandler?.taskResponder.didComplete(taskHandler?.data, task.response, error)
            
            tasks[task.taskIdentifier] = nil
        }
    }
}

extension SessionDelegate: URLSessionDataDelegate {
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        completionHandler(.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        serialQueue.sync {
            tasks[dataTask.taskIdentifier]?.data.append(data)
            
            let bytes = Int64(data.count)
            tasks[dataTask.taskIdentifier]?.totalBytesRecieved += bytes
            
            let totalBytes = dataTask.response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            
            tasks[dataTask.taskIdentifier]?.progress.totalUnitCount = totalBytes
            tasks[dataTask.taskIdentifier]?.progress.completedUnitCount = tasks[dataTask.taskIdentifier]?.totalBytesRecieved ?? 0
            
            
            if let progressBlock = tasks[dataTask.taskIdentifier]?.progressBlock,
                let progress = tasks[dataTask.taskIdentifier]?.progress {
                progressBlock(ProgressResponse(progress: progress))
            }
        }
    }
}
