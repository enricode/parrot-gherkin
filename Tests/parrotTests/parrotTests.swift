import XCTest
@testable import parrot

final class parrotTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(parrot().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
