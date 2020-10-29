//
//  CustomEncoderTests.swift
//  Serializable
//
//  Created by Yehor Popovych on 10/29/20.
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

class CustomEncoderTests: XCTestCase {
    static let encoder: JSONEncoder = {
        var encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .hex
        encoder.dateEncodingStrategy = .iso8601millis
        return encoder
    }()
    
    static let decoder: JSONDecoder = {
        var encoder = JSONDecoder()
        encoder.dateDecodingStrategy = .iso8601millis
        return encoder
    }()
    
    func testHexDataDecoding() {
        let json = "{\"data\":\"0102030A0FBADDEF\"}".data(using: .utf8)!
        let data = Data([0x01, 0x02, 0x03, 0x0a, 0x0f, 0xba, 0xdd, 0xef])
        let value = try? Self.decoder.decode(SerializableValue.self, from: json)
        XCTAssertEqual(value?.object?["data"]?.bytes(.hex), data)
    }
    
    func testBase64DataDecoding() {
        let json = "{\"data\":\"dGVzdA==\"}".data(using: .utf8)!
        let data = "test".data(using: .utf8)!
        let value = try? Self.decoder.decode(SerializableValue.self, from: json)
        XCTAssertEqual(value?.object?["data"]?.bytes(.base64), data)
    }

    func testHexDataEncoding() {
        var dictionary = Dictionary<String, SerializableValue>()
        dictionary["data"] = Data([0x01, 0x02, 0x03, 0x0a, 0x0f, 0xba, 0xdd, 0xef]).serializable
        let json = "{\"data\":\"0102030a0fbaddef\"}".data(using: .utf8)!
        let encoded = try? Self.encoder.encode(dictionary)
        XCTAssertEqual(encoded, json)
    }
    
    func testHex0xDataEncoding() {
        var dictionary = Dictionary<String, SerializableValue>()
        dictionary["data"] = Data([0x01, 0x02, 0x03, 0x0a, 0x0f, 0xba, 0xdd, 0xef]).serializable
        let json = "{\"data\":\"0x0102030a0fbaddef\"}".data(using: .utf8)!
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .prefixedHex
        let encoded = try? encoder.encode(dictionary)
        XCTAssertEqual(encoded, json)
    }
}
