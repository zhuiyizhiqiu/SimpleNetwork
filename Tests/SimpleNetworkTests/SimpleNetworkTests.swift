import XCTest
@testable import SimpleNetwork

final class SimpleNetworkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(SimpleNetwork().text, "Hello, World!")
        struct abc:Codable{
            var value = 0
        }
        let a = abc(value: 20)
        
        let encode = try! JSONEncoder().encode(a)
        let decode = try! JSONDecoder().decode(abc.self, from: encode)
        XCTAssertEqual(a.value, decode.value)
        struct text: Codable {
            var status = 0
        }
        let network = SimpleNetwork.simpleNetwork
        let head = ["userId":"341"]
        network.request(url: "http://192.168.110.194:9999/vehiclePublicInformation/getAllCompany", head: head){ (result, data:text?) in
        switch result{
        case .failure(let error,_):
            print(error)
        case .success:
            print(data!)
            XCTAssertEqual(data!.status, 20)

            }
        }
        
//        XCTAssertEqual(status, 200)
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
