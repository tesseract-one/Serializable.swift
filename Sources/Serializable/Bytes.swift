//
//  Bytes.swift
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

extension SerializableValue.DataDecodingStrategy {
    public static let base64 = Self { input in
        if case .bytes(let data) = input.serializable { return data }
        guard case .string(let string) = input.serializable else {
            throw SerializableValue.Error.notInitializable(input.serializable)
        }
        guard let data = Data(base64Encoded: string) else {
            throw SerializableValue.Error.notInitializable(input.serializable)
        }
        return data
    }
    
    public static let hex = Self { input in
        if case .bytes(let data) = input.serializable { return data }
        guard case .string(let string) = input.serializable else {
            throw SerializableValue.Error.notInitializable(input.serializable)
        }
        let scalars = string.unicodeScalars
        guard scalars.count % 2 == 0 else {
            throw SerializableValue.Error.notInitializable(input.serializable)
        }
        let prefix = string.hasPrefix("0x") ? 2 : 0
        var result = Data(repeating: 0, count: (scalars.count - prefix) / 2)
        var current: UInt8? = nil
        for cIdx in prefix..<scalars.count {
            let idx = scalars.index(scalars.startIndex, offsetBy: cIdx)
            let v: UInt8
            switch UInt8(scalars[idx].value) {
            case let c where c <= 57: v = c - 48
            case let c where c >= 65 && c <= 70: v = c - 55
            case let c where c >= 97: v = c - 87
            default:
                throw SerializableValue.Error.notInitializable(input.serializable)
            }
            if let val = current {
                result[cIdx/2] = val << 4 | v
                current = nil
            } else {
                current = v
            }
        }
        return result
    }
}
