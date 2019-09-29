import XCTest
@testable import MiniNe

final class MiniNeClientTests: XCTestCase {
    
    var client: MiniNeClient!
    var session: MockSessionDelegate!
    
    override func setUp() {
        super.setUp()
        
        session = MockSessionDelegate()
        
        let configuration = URLSessionConfiguration.default
        
        client = MiniNeClient(configuration: configuration, delegate: session)
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
        
        let expectation = XCTestExpectation(description: "test")

        
        client.send(request: request) { (result) in
            switch result {
                
            case .success(let response):
                XCTAssertTrue(expectedData == response.data)
                XCTAssertTrue(expectedStatusCode == response.statusCode)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testInvalidURL_ReturnsError() {
        let request = MockStandardRequest.invalidRequest
        
        let expectation = XCTestExpectation(description: "test")

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
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testConnectionError() {

        enum MockError: Error, Equatable {
            case failure
        }

        let request = MockStandardRequest.validRequest

        session.mockError = MockError.failure

        let expectation = XCTestExpectation(description: "test")
        
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
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testUnacceptableStatusCodes() {

        let request = MockStandardRequest.validRequest

        let expectedData = "{}".data(using: .utf8)
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 400,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)

        let expectation = XCTestExpectation(description: "test")
        
        client.send(request: request) { (result) in
            switch result {

            case .success:
                XCTFail("There was an error. Should not be successful!")
            case .failure(let error):

                switch error {
                case .responseValidationFailed(let response):
                    XCTAssertTrue(response.statusCode == 400)
                default:
                    XCTFail("Incorrect Error")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testErrorResponseValidation_WithErrorData() {

        struct MockErrorResponse: Decodable {
            let error: String
        }

        let request = MockStandardRequest.validRequest

        let expectedData =
            """
                {
                    "error": "foo"
                }
            """
                .data(using: .utf8)!
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: 400,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)

        let expectation = XCTestExpectation(description: "test")
        
        client.send(request: request) { (result) in
            switch result {

            case .success:
                XCTFail("There was an error. Should not be successful!")
            case .failure(let error):

                let response = error.response!
                let jsonDecoder = JSONDecoder()
                let responseError = try! jsonDecoder.decode(MockErrorResponse.self, from: response.data)
                XCTAssertTrue(responseError.error == "foo")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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

        let expectation = XCTestExpectation(description: "test")
        
        client.send(responseType: Foo.self, request: request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.object.foo == "bar")
                XCTAssertTrue(response.object.fooz == "barz")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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

        let expectation = XCTestExpectation(description: "test")
        
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

                let response = error.response!

                XCTAssertTrue(response.statusCode == 200)

            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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

        let expectation = XCTestExpectation(description: "test")
        
        client.send(responseType: Bar.self, request: request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.object.bar == "foo")
                XCTAssertTrue(response.object.barz == "fooz")
                XCTAssertTrue(Thread.isMainThread)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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

        let expectation = XCTestExpectation(description: "test")
        
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
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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

        let expectation = XCTestExpectation(description: "test")
        
        client.send(codableRequest: request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.object.foo == "bar")
                XCTAssertTrue(response.object.fooz == "barz")
                XCTAssertTrue(Thread.isMainThread)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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

        let expectation = XCTestExpectation(description: "test")
        
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
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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
        let expectation = XCTestExpectation(description: "test")
        
        client.send(jsonRequest: request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.object.bar == "foo")
                XCTAssertTrue(response.object.barz == "fooz")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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

        let expectation = XCTestExpectation(description: "test")
        
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
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDefaultCallbackQueue() {
        let request = MockStandardRequest.validRequest
        
        let expectedData = "{}".data(using: .utf8)
        let expectedStatusCode = 200
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: expectedStatusCode,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        let expectation = XCTestExpectation(description: "test")

        client.send(request: request) { (result) in
            
            XCTAssertTrue(Thread.isMainThread)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSettingCallbackQueue() {
        let request = MockStandardRequest.validRequest
        
        let expectedData = "{}".data(using: .utf8)
        let expectedStatusCode = 200
        session.mockData = expectedData
        session.mockURLResponse = HTTPURLResponse(url: request.url!,
                                                  statusCode: expectedStatusCode,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        
        let expectation = XCTestExpectation(description: "test")
        
        let testQueue = DispatchQueue(label: "dawdwa", qos: .utility)

        client.send(request: request, callBackQueue: testQueue) { (result) in
            
            XCTAssertTrue(!Thread.isMainThread)
            XCTAssertTrue(Thread.current.qualityOfService == .utility)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    static var allTests = [
        ("testSuccessfulRequest", testBasicSuccessfulRequest),
    ]
}
