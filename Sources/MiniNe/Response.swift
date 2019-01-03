import Foundation

public class Response {
    public let statusCode: Int
    public let data: Data
    
    /// The requesting URL. This may not be the original url if there was a redirect.
    /// TODO: should change?
    public let requestURL: URL?
    
    public init(statusCode: Int, data: Data, requestURL: URL?) {
        self.statusCode = statusCode
        self.data = data
        self.requestURL = requestURL
    }
}

public extension Response {
    func isValid(statusCodes: [Int]) -> Bool {
        return statusCodes.contains(statusCode)
    }
}
