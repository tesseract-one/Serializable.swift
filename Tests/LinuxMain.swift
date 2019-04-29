import XCTest

import SerializableTests

var tests = [XCTestCaseEntry]()
tests += SerializableTests.__allTests()

XCTMain(tests)
