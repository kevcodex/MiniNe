import XCTest
@testable import MiniNe

final class MiniNeClientTests: XCTestCase {
    
    var client: MiniNeClient!
    var session: MockURLSession!
    
    override func setUp() {
        super.setUp()
        
        session = MockURLSession()
        client = MiniNeClient(session: session)
    }
    
    func testBasicSuccessfulRequest() {
        let request = MockStandardRequest.validRequest
        
        let expectedData = "{}".data(using: .utf8)
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(request: request) { (result) in
            switch result {
                
            case .success(let response):
                XCTAssertTrue(expectedData == response.data)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testInvalidURL_ReturnsError() {
        let request = MockStandardRequest.invalidRequest
        
        client.send(request: request) { (result) in
            switch result {
                
            case .success:
                XCTFail("URL is invalid! Should not get a success.")
            case .failure(let error):
                
                switch error {
                case .badRequest:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Incorrect Error")
                }
            }
        }
    }
    

    static var allTests = [
        ("testSuccessfulRequest", testBasicSuccessfulRequest),
    ]
}
