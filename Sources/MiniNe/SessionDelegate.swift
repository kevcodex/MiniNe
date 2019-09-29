//
//  SessionDelegate
//  
//
//  Created by Kevin Chen on 9/22/19.
//

import Foundation

open class SessionDelegate: NSObject {
    
    public var totalBytesRecieved: Int64 = 0
    
    public var progress: Progress
    
    public var progressBlock: ((ProgressResponse) -> Void)?
    
    public var test: ((Data?, URLResponse?, Error?) -> Void)?
    
    public var data: Data
    
    public override init() {
        
        data = Data()
        progress = Progress(totalUnitCount: 0)
        
        super.init()
    }
}

extension SessionDelegate: URLSessionDelegate {

    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        test?(data, task.response, error)
        
    }
}

extension SessionDelegate: URLSessionDataDelegate {
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        completionHandler(.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        self.data.append(data)
        
        let bytes = Int64(data.count)
        totalBytesRecieved += bytes
        
        let totalBytes = dataTask.response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
        
        progress.totalUnitCount = totalBytes
        progress.completedUnitCount = totalBytesRecieved
        
        
        if let progressBlock = progressBlock {
            progressBlock(ProgressResponse(progress: progress))
        }
        
    }
    
    
}
