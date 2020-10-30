//
//  Value.swift
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

public enum SerializableValue: Codable, Equatable, Hashable {
    case `nil`
    case bool(Bool)
    case int(Int64)
    case float(Double)
    case string(String)
    case date(Date)
    case bytes(Data)
    case array(Array<SerializableValue>)
    case object(Dictionary<String, SerializableValue>)
    
    public init(_ value: SerializableValueRepresentable) {
        self = value.serializable
    }

    public init(_ array: Array<SerializableValueRepresentable>) {
        self = .array(array.map { $0.serializable })
    }

    public init(_ dict: Dictionary<String, SerializableValueRepresentable>) {
        self = .object(dict.mapValues{ $0.serializable })
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
        } else if let array = try? container.decode([SerializableValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: SerializableValue].self) {
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
    
    public enum Error: Swift.Error {
        case notInitializable(SerializableValue)
    }
    
    public struct DataDecodingStrategy {
        public let decode: (SerializableValueRepresentable) throws -> Data
        
        public init(decode: @escaping (SerializableValueRepresentable) throws -> Data) {
            self.decode = decode
        }
    }
    
    public struct DateDecodingStrategy {
        public let decode: (SerializableValueRepresentable) throws -> Date
        
        public init(decode: @escaping (SerializableValueRepresentable) throws -> Date) {
            self.decode = decode
        }
    }
}

extension SerializableValue: SerializableValueConvertible {
    public init(serializable: SerializableValue) throws {
        self = serializable
    }
    
    public var serializable: SerializableValue { self }
}

extension SerializableValue: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .nil: return "null"
        case .int(let int): return "\(int)"
        case .float(let num): return "\(num)"
        case .bool(let bool): return bool ? "true" : "false"
        case .date(let date): return "\"\(DateFormatter.iso8601millis.string(from: date))\""
        case .string(let str): return "\"\(str)\""
        case .bytes(let data):
            return "\"\(JSONEncoder.DataEncodingStrategy.srv_encodeHex(data: data, prefix: false))\""
        case .array(let arr):
            return "[\(arr.map{String(describing: $0)}.joined(separator: ", "))]"
        case .object(let obj):
            return "{\(obj.map{"\"\($0)\": \(String(describing: $1))"}.joined(separator: ", "))}"
        }
    }
}
