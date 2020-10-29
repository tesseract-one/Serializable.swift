//
//  FoundationExtensions.swift
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

extension Int64: SerializableValueCodable {
    public init(serializable: SerializableValue) throws {
        guard case .int(let int) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = int
    }
    public var serializable: SerializableValue { .int(self) }
}

extension SerializableValue: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int64

    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension SerializableValue {
    public var int: Int64? {
        switch self {
        case .int(let int): return int
        case .float(let float): return Int64(float)
        default: return nil
        }
    }
}

extension Double: SerializableValueCodable {
    public init(serializable: SerializableValue) throws {
        guard case .float(let num) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = num
    }
    public var serializable: SerializableValue { .float(self) }
}

extension SerializableValue: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .float(value)
    }
}

extension SerializableValue {
    public var float: Double? {
        switch self {
        case .int(let int): return Double(int)
        case .float(let float): return float
        default: return nil
        }
    }
}

extension Bool: SerializableValueCodable {
    public init(serializable: SerializableValue) throws {
        guard case .bool(let bool) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = bool
    }
    public var serializable: SerializableValue { .bool(self) }
}

extension SerializableValue: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension SerializableValue {
    public var bool: Bool? {
        guard case .bool(let bool) = self else { return nil }
        return bool
    }
}

extension Date: SerializableValueCodable {
    public init(serializable: SerializableValue) throws {
        guard case .date(let date) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = date
    }
    
    public var serializable: SerializableValue { .date(self) }
}

extension SerializableValue {
    public var date: Date? { date() }
    
    public func date(_ decoder: DateDecodingStrategy = .deferredToParser) -> Date? {
        try? decoder.decode(self)
    }
}

extension Data: SerializableValueCodable {
    public init(serializable: SerializableValue) throws {
        guard case .bytes(let data) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = data
    }
    
    public var serializable: SerializableValue { .bytes(self) }
}

extension SerializableValue {
    public var bytes: Data? { bytes() }
    
    public func bytes(_ decoder: DataDecodingStrategy = .base64) -> Data? {
        try? decoder.decode(self)
    }
}

extension String: SerializableValueCodable {
    public init(serializable: SerializableValue) throws {
        guard case .string(let str) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = str
    }
    
    public var serializable: SerializableValue { .string(self) }
}

extension SerializableValue: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension SerializableValue {
    public var string: String? {
        guard case .string(let str) = self else { return nil }
        return str
    }
}

extension Array: SerializableValueEncodable where Element: SerializableValueEncodable {
    public var serializable: SerializableValue {
        .array(self.map{$0.serializable})
    }
}

extension Array: SerializableValueDecodable where Element: SerializableValueDecodable {
    public init(serializable: SerializableValue) throws {
        guard case .array(let array) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = try array.map{ try Element(serializable: $0) }
    }
}

extension SerializableValue: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = SerializableValueEncodable
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension SerializableValue {
    public var array: Array<SerializableValue>? {
        guard case .array(let array) = self else { return nil }
        return array
    }
}

extension Dictionary: SerializableValueDecodable where Key == String, Value: SerializableValueDecodable {
    public init(serializable: SerializableValue) throws {
        guard case .object(let obj) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = try obj.mapValues { try Value(serializable: $0) }
    }
}

extension Dictionary: SerializableValueEncodable where Key == String, Value: SerializableValueEncodable {
    public var serializable: SerializableValue {
        .object(self.mapValues{$0.serializable})
    }
}

extension SerializableValue: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = SerializableValueEncodable
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements) )
    }
}

extension SerializableValue {
    public var object: Dictionary<String, SerializableValue>? {
        guard case .object(let obj) = self else { return nil }
        return obj
    }
}

extension Optional: SerializableValueEncodable where Wrapped: SerializableValueEncodable {
    public var serializable: SerializableValue {
        switch self {
        case .none: return .nil
        case .some(let val): return val.serializable
        }
    }
}
extension Optional: SerializableValueDecodable where Wrapped: SerializableValueDecodable {
    public init(serializable: SerializableValue) throws {
        switch serializable {
        case .nil: self = .none
        default: self = try .some(Wrapped(serializable: serializable))
        }
    }
}

extension Optional {
    public static var `nil`: SerializableValueCodable { SerializableValue.nil }
}

extension SerializableValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension SerializableValue {
    public var isNil: Bool { self == .nil }
}
