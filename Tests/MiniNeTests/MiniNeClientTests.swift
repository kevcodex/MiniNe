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
        let expectedStatusCode = 200
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: expectedStatusCode,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(request: request) { (result) in
            switch result {
                
            case .success(let response):
                XCTAssertTrue(expectedData == response.data)
                XCTAssertTrue(expectedStatusCode == response.statusCode)
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
    
    func testConnectionError() {
        
        enum MockError: Error, Equatable {
            case failure
        }
        
        let request = MockStandardRequest.validRequest
        
        session.mockError = MockError.failure
        
        client.send(request: request) { (result) in
            switch result {
                
            case .success:
                XCTFail("There was an error. Should not be successful!")
            case .failure(let error):
                
                switch error {
                case .connectionError(let error):
                    let error = error as? MockError
                    XCTAssertTrue(error == MockError.failure)
                default:
                    XCTFail("Incorrect Error")
                }
            }
        }
    }
    
    func testUnacceptableStatusCodes() {
        
        let request = MockStandardRequest.validRequest
        
        let expectedData = "{}".data(using: .utf8)
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 400,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(request: request) { (result) in
            switch result {
                
            case .success:
                XCTFail("There was an error. Should not be successful!")
            case .failure(let error):
                
                switch error {
                case .responseValidationFailed(let failure):
                    switch failure {
                    case .invalidStatusCode(let code):
                        XCTAssertTrue(code == 400)
                    }
                default:
                    XCTFail("Incorrect Error")
                }
            }
        }
    }
    
    func testSuccessfullRequest_ForCodableRequestType() {
        
        let expectedData =
        """
            {
                "foo": "bar",
                "fooz": "barz"
            }
        """
            .data(using: .utf8)!
        
        let request = MockStandardRequest.validRequest
        
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(responseType: Foo.self, request: request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.object.foo == "bar")
                XCTAssertTrue(response.object.fooz == "barz")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Request Type Tests
    func testRequest_ForCodableRequestType_WithDecodingError() {
        
        let skewedData =
            """
                {
                    "fooaaaa": "bar",
                    "fooz": "barz"
                }
            """
                .data(using: .utf8)!
        
        let request = MockStandardRequest.validRequest
        
        session.mockData = skewedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(responseType: Foo.self, request: request) { (result) in
            switch result {
            case .success:
                XCTFail("There was an error. Should not be successful!")
            case .failure(let error):
                switch error {
                case .responseParseError:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Incorrect Error")
                }
            }
        }
    }
    
    func testSuccessfulRequest_ForJSONDecodableRequestType() {
        
        let expectedData =
            """
                {
                    "bar": "foo",
                    "barz": "fooz"
                }
            """
                .data(using: .utf8)!
        
        let request = MockStandardRequest.validRequest
        
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(responseType: Bar.self, request: request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.object.bar == "foo")
                XCTAssertTrue(response.object.barz == "fooz")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testRequest_ForJSONDecodableRequestType_WithDecodingError() {
        
        let skewedData =
            """
                {
                    "fooaaaa": "bar",
                    "fooz": "barz"
                }
            """
                .data(using: .utf8)!
        
        let request = MockStandardRequest.validRequest
        
        session.mockData = skewedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(responseType: Bar.self, request: request) { (result) in
            switch result {
            case .success:
                XCTFail("There was an error. Should not be successful!")
            case .failure(let error):
                switch error {
                case .responseParseError:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Incorrect Error")
                }
            }
        }
    }
    
    // MARK: - Associated Request Type Tests
    func testSuccessfullRequest_ForCodableRequest() {
        
        let expectedData =
            """
                {
                    "foo": "bar",
                    "fooz": "barz"
                }
            """
                .data(using: .utf8)!
        
        let request = MockCodableRequest()
        
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(codableRequest: request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.object.foo == "bar")
                XCTAssertTrue(response.object.fooz == "barz")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testRequest_ForCodableRequest_WithDecodingError() {
        
        let skewedData =
            """
                {
                    "fooaaaa": "bar",
                    "fooz": "barz"
                }
            """
                .data(using: .utf8)!
        
        let request = MockCodableRequest()
        
        session.mockData = skewedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(codableRequest: request) { (result) in
            switch result {
            case .success:
                XCTFail("There was an error. Should not be successful!")
            case .failure(let error):
                switch error {
                case .responseParseError:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Incorrect Error")
                }
            }
        }
    }
    
    func testSuccessfulRequest_ForJSONDecodableRequest() {
        
        let expectedData =
            """
                {
                    "bar": "foo",
                    "barz": "fooz"
                }
            """
                .data(using: .utf8)!
        
        let request = MockJSONDecodableRequest()
        
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(jsonRequest: request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.object.bar == "foo")
                XCTAssertTrue(response.object.barz == "fooz")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testRequest_ForJSONDecodableRequest_WithDecodingError() {
        
        let skewedData =
            """
                {
                    "fooaaaa": "bar",
                    "fooz": "barz"
                }
            """
                .data(using: .utf8)!
        
        let request = MockJSONDecodableRequest()

        session.mockData = skewedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 200,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        client.send(jsonRequest: request) { (result) in
            switch result {
            case .success:
                XCTFail("There was an error. Should not be successful!")
            case .failure(let error):
                switch error {
                case .responseParseError:
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
