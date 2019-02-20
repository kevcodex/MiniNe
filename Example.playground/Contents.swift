import MiniNe
import Foundation
import PlaygroundSupport

struct ExampleNetworkRequest: NetworkRequest {
    var baseURL: URL? {
        return URL(string: "http://httpbin.org/post")
    }
    
    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var headers: [String : Any]? {
        return nil
    }
    
    var body: NetworkBody?
}

struct Foo: Codable {
    let text: String
}

let foo = Foo(text: "Hello World")

guard let data = try? JSONEncoder().encode(foo) else {
    fatalError()
}

let request = ExampleNetworkRequest(body: NetworkBody(data: data, encoding: .json))

let client = MiniNeClient()
client.send(request: request) { (result) in
    print(result)
    PlaygroundPage.current.finishExecution()
}

PlaygroundPage.current.needsIndefiniteExecution = true

