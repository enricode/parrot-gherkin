import XCTest

import parrotTests

var tests = [XCTestCaseEntry]()
tests += parrotTests.allTests()
XCTMain(tests)