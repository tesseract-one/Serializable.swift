//
//  AnyValue.swift
//  Serializable
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

import Foundation

public enum AnyValue: Codable, Equatable, Hashable {
    case `nil`
    case bool(Bool)
    case int(Int64)
    case float(Double)
    case string(String)
    case date(Date)
    case bytes(Data)
    case array(Array<Self>)
    case object(Dictionary<String, Self>)
    
    public init(_ value: AnyValueConvertible) {
        self = value.anyValue
    }

    public init(_ array: Array<AnyValueConvertible>) {
        self = .array(array.map { $0.anyValue })
    }

    public init(_ dict: Dictionary<String, AnyValueConvertible>) {
        self = .object(dict.mapValues{ $0.anyValue })
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .nil
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int64.self) {
            self = .int(int)
        } else if let float = try? container.decode(Double.self) {
            self = .float(float)
        } else if let date = try? container.decode(Date.self) {
            self = .date(date)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let data = try? container.decode(Data.self) {
            self = .bytes(data)
        } else if let array = try? container.decode([Self].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: Self].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown value type"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .nil: try container.encodeNil()
        case .bool(let bool): try container.encode(bool)
        case .int(let int): try container.encode(int)
        case .float(let num): try container.encode(num)
        case .date(let date): try container.encode(date)
        case .bytes(let data): try container.encode(data)
        case .string(let str): try container.encode(str)
        case .array(let arr): try container.encode(arr)
        case .object(let obj): try container.encode(obj)
        }
    }
}

public extension AnyValue {
    struct NotInitializable: Error {
        public let type: String
        public let from: AnyValue
        public init(type: String, from: AnyValue) {
            self.type = type
            self.from = from
        }
    }
}

extension AnyValue: AnyValueRepresentable {
    public init(anyValue: AnyValue) throws {
        self = anyValue
    }
    
    public var anyValue: AnyValue { self }
}

extension AnyValue: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .nil: return "null"
        case .int(let int): return "\(int)"
        case .float(let num): return "\(num)"
        case .bool(let bool): return bool ? "true" : "false"
        case .date(let date): return "\"\(DateFormatter.sz_iso8601millis.string(from: date))\""
        case .string(let str): return "\"\(str)\""
        case .bytes(let data):
            return "\"\(JSONEncoder.DataEncodingStrategy.sz_encodeHex(data: data, prefix: false))\""
        case .array(let arr):
            return "[\(arr.map{String(describing: $0)}.joined(separator: ", "))]"
        case .object(let obj):
            return "{\(obj.map{"\"\($0)\": \(String(describing: $1))"}.joined(separator: ", "))}"
        }
    }
}
