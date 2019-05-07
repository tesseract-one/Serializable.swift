//
//  SerializableValue.swift
//  Serializable
//
//  Created by Yehor Popovych on 3/28/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
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

public enum SerializableValue: Codable, SerializableProtocol, Equatable, Hashable {
    case `nil`
    case bool(Bool)
    case int(Int)
    case float(Double)
    case string(String)
    case array(Array<SerializableValue>)
    case object(Dictionary<String, SerializableValue>)
    
    public init(_ serializable: SerializableValue) {
        self = serializable
    }
    
    public init(from value: SerializableValueEncodable) {
        self = value.serializable
    }
    
    public init(_ dict: Dictionary<String, SerializableValueEncodable>) {
        self = .object(dict.mapValues{ $0.serializable })
    }
    
    public var serializable: SerializableValue {
        return self
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .nil
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let float = try? container.decode(Double.self) {
            self = .float(float)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([SerializableValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: SerializableValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown value type")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .nil: try container.encodeNil()
        case .bool(let bool): try container.encode(bool)
        case .int(let int): try container.encode(int)
        case .float(let num): try container.encode(num)
        case .string(let str): try container.encode(str)
        case .array(let arr): try container.encode(arr)
        case .object(let obj): try container.encode(obj)
        }
    }
    
    public enum Error: Swift.Error {
        case notInitializable(SerializableValue)
    }
}

private struct CustomCodingKeys: CodingKey {
    let stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? { return nil }
    init?(intValue: Int) { return nil }
}
