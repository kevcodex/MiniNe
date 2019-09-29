//
//  SessionDelegate
//  
//
//  Created by Kevin Chen on 9/22/19.
//

import Foundation

// TODO: - Currently only handles data session, but I believe a fairly straightforward refactor can allow for supporting other sessions like download
open class SessionDelegate: NSObject {
    
    public private(set) var tasks = ThreadSafeDictionary<Int, TaskHandler>()
    
    public override init() {
        super.init()
    }
    
    public func addTaskHandler(_ taskHandler: TaskHandler, for task: URLSessionDataTask) {
        tasks[task.taskIdentifier] = taskHandler
    }
}

extension SessionDelegate: URLSessionDelegate {

    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
                
        let taskHandler = tasks[task.taskIdentifier]
        
        taskHandler?.taskResponder.didComplete(taskHandler?.data, task.response, error)
        
        self.tasks[task.taskIdentifier] = nil
    }
}

extension SessionDelegate: URLSessionDataDelegate {
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        completionHandler(.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let taskHandler = tasks[dataTask.taskIdentifier] else {
            return
        }
        
        taskHandler.data.append(data)
        
        let bytes = Int64(data.count)
        taskHandler.totalBytesRecieved += bytes
        
        let totalBytes = dataTask.response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
        
        taskHandler.progress.totalUnitCount = totalBytes
        taskHandler.progress.completedUnitCount = taskHandler.totalBytesRecieved
        
        if let progressHandler = taskHandler.progressHandler {
            
            progressHandler.callbackQueue.async {
                progressHandler.progressBlock(ProgressResponse(progress: taskHandler.progress))
            }
        }
    }
}
