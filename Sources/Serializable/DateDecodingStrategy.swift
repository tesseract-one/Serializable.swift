//
//  DateDecodingStrategy.swift
//  Serializable
//
//  Created by Yehor Popovych on 10/30/20.
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

public extension AnyValue {
    struct DateDecodingStrategy {
        public let decode: (AnyValueConvertible) throws -> Date
        
        public init(decode: @escaping (AnyValueConvertible) throws -> Date) {
            self.decode = decode
        }
    }
}

public extension AnyValue.DateDecodingStrategy {
    /// Return Date only if parser can parse it.
    static let deferredToDate = Self { input in
        return try Date(anyValue: input.anyValue)
    }
    
    /// Decode the `Date` as a ISO8601 string with milliseconds.
    static let iso8601millis = Self { input in
        switch input.anyValue {
        case .date(let date): return date
        case .string(let str):
            guard let date = DateFormatter.sz_iso8601millis.date(from: str) else {
                throw AnyValue.NotInitializable(type: "Date", from: input.anyValue)
            }
            return date
        default:
            throw AnyValue.NotInitializable(type: "Date", from: input.anyValue)
        }
    }
    
    /// Decode the `Date` as a UNIX timestamp from a JSON number.
    static let secondsSince1970 = Self { input in
        switch input.anyValue {
        case .date(let date): return date
        case .int(let int): return Date(timeIntervalSince1970: TimeInterval(int))
        case .float(let float): return Date(timeIntervalSince1970: TimeInterval(float))
        default:
            throw AnyValue.NotInitializable(type: "Date", from: input.anyValue)
        }
    }

    /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
    static let millisecondsSince1970 = Self { input in
        switch input.anyValue {
        case .date(let date): return date
        case .int(let int): return Date(timeIntervalSince1970: TimeInterval(int) / 1000.0)
        case .float(let float): return Date(timeIntervalSince1970: TimeInterval(float) / 1000.0)
        default:
            throw AnyValue.NotInitializable(type: "Date", from: input.anyValue)
        }
    }
}
