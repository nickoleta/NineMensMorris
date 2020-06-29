import XCTest
@testable import nine_mens_morris

final class nine_mens_morrisTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(nine_mens_morris().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
