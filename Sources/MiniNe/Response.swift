import Foundation

public class Response {
    public let statusCode: Int
    
    public let data: Data
    
    public init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }
}

public extension Response {
    func isValid(statusCodes: [Int]) -> Bool {
        return statusCodes.contains(statusCode)
    }
}
