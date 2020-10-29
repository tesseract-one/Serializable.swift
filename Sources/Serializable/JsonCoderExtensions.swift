//
//  JsonCoderExtensions.swift
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

import Foundation

extension Formatter {
    public static let iso8601millis: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    public static let iso8601millis = formatted(.iso8601millis)
}

extension JSONEncoder.DateEncodingStrategy {
    public static let iso8601millis = formatted(.iso8601millis)
}

extension JSONEncoder.DataEncodingStrategy {
    private static let _srv_characters: [UInt8] = [
        UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"),
        UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "7"),
        UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "a"), UInt8(ascii: "b"),
        UInt8(ascii: "c"), UInt8(ascii: "d"), UInt8(ascii: "e"), UInt8(ascii: "f")
    ]
    
    public static func srv_encodeHex(data: Data, prefix: Bool) -> String {
        var result = Array<UInt8>()
        result.reserveCapacity(data.count * 2 + (prefix ? 2 : 0))
        if prefix {
            result.append(UInt8(ascii: "0"))
            result.append(UInt8(ascii: "x"))
        }
        for byte in data {
            result.append(Self._srv_characters[Int(byte >> 4)])
            result.append(Self._srv_characters[Int(byte & 0x0F)])
        }
        return String(bytes: result, encoding: .ascii)!
    }
    
    public static let hex = custom { (data, encoder) in
        var container = encoder.singleValueContainer()
        try container.encode(Self.srv_encodeHex(data: data, prefix: false))
    }
    
    public static let prefixedHex = custom { (data, encoder) in
        var container = encoder.singleValueContainer()
        try container.encode(Self.srv_encodeHex(data: data, prefix: true))
    }
}
