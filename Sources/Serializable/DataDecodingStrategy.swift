//
//  DataDecodingStrategy.swift
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

public extension AnyValue {
    struct DataDecodingStrategy {
        public let decode: (AnyValueConvertible) throws -> Data
        
        public init(decode: @escaping (AnyValueConvertible) throws -> Data) {
            self.decode = decode
        }
    }
}

public extension AnyValue.DataDecodingStrategy {
    static let deferredToData = Self { input in
        return try Data(anyValue: input.anyValue)
    }
    
    static let base64 = Self { input in
        let value = input.anyValue
        if case .bytes(let data) = value { return data }
        guard case .string(let string) = value else {
            throw AnyValue.NotInitializable(type: "Data", from: value)
        }
        guard let data = Data(base64Encoded: string) else {
            throw AnyValue.NotInitializable(type: "Data", from: value)
        }
        return data
    }
    
    static let hex = Self { input in
        let value = input.anyValue
        if case .bytes(let data) = value { return data }
        guard case .string(let string) = value else {
            throw AnyValue.NotInitializable(type: "Data", from: value)
        }
        guard let data = string.data(using: .ascii), data.count % 2 == 0 else {
            throw AnyValue.NotInitializable(type: "Data", from: value)
        }
        let prefix = string.hasPrefix("0x") ? 2 : 0
        let parsed: Data = try data.withUnsafeBytes() { hex in
            var result = Data()
            result.reserveCapacity((hex.count - prefix) / 2)
            var current: UInt8? = nil
            for indx in prefix ..< hex.count {
                let v: UInt8
                switch hex[indx] {
                case let c where c <= 57: v = c - 48
                case let c where c >= 65 && c <= 70: v = c - 55
                case let c where c >= 97: v = c - 87
                default:
                    throw AnyValue.NotInitializable(type: "Data", from: value)
                }
                if let val = current {
                    result.append(val << 4 | v)
                    current = nil
                } else {
                    current = v
                }
            }
            return result
        }
        return parsed
    }
}
