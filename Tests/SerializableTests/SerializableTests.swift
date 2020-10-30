//
//  SerializableTests.swift
//  SerializableTests
//
//  Created by Yehor Popovych on 3/28/19.
//  Copyright © 2020 Tesseract Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import Serializable

class SerializableTests: XCTestCase {
    func parseAndCheck(data: Data) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601millis
        let value = try? decoder.decode(SerializableValue.self, from: data)
        let obj = value?.object
        XCTAssertEqual(obj?["int"]?.int, -123)
        XCTAssertEqual(obj?["array"]?.array?.tryParse(Int64.self), [1, 2, 3])
        XCTAssertEqual(obj?["array"]?.array?[2].int, 3)
        XCTAssertEqual(obj?["float"]?.float, 123.456)
        XCTAssertEqual(obj?["date"]?.date, Date(timeIntervalSince1970: 1569477510.996))
        XCTAssertEqual(obj?["bytes"]?.bytes, "test".data(using: .utf8))
        XCTAssertEqual(obj?["string"]?.string, "test")
        XCTAssertEqual(obj?["bool"]?.bool, false)
        XCTAssertEqual(obj?["optional"]?.isNil, true)
        XCTAssertEqual(obj?["object"]?.object?["a"]?.string, "b")
    }
    
    func testDecoding() {
        let json = """
        { "array": [1, 2, 3], "int": -123, "float": 123.456,
          "date": "2019-09-26T07:58:30.996+0200", "bytes": "dGVzdA==",
          "string": "test", "bool": false, "optional": null,
          "object": {"a": "b"}
        }
        """
        parseAndCheck(data: json.data(using: .utf8)!)
    }
    
    func testEncoding() {
        var object = Dictionary<String, SerializableValueRepresentable>()
        object["int"] = Int64(-123)
        object["array"] = [Int64(1), Int64(2), Int64(3)]
        object["float"] = 123.456
        object["date"] = Date(timeIntervalSince1970: 1569477510.996)
        object["bytes"] = "test".data(using: .utf8)
        object["string"] = "test"
        object["bool"] = false
        object["optional"] = .nil
        object["object"] = ["a": "b"]
        
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .iso8601millis
        let data = try? encoder.encode(SerializableValue(object))
        XCTAssertNotNil(data)
        if let data = data {
            parseAndCheck(data: data)
        }
    }
}
