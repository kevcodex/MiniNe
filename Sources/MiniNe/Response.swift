import Foundation

public class Response {
    public let statusCode: Int
    public let data: Data
    
    /// The original URLRequest for the response.
    /// The requesting URLRequest. This may not be the original url if there was a redirect.
    public let request: URLRequest?
    
    public let httpResponse: HTTPURLResponse?
    
    public init(statusCode: Int, data: Data, request: URLRequest?, httpResponse: HTTPURLResponse?) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.httpResponse = httpResponse
    }
}

public extension Response {
    func isValid(statusCodes: [Int]) -> Bool {
        return statusCodes.contains(statusCode)
    }
}
