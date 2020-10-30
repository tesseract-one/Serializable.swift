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

extension Int64: SerializableValueRepresentable {
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
    public var int: Int64? { try? Int64(serializable: self) }
}

extension Double: SerializableValueRepresentable {
    public init(serializable: SerializableValue) throws {
        switch serializable {
        case .float(let num): self = num
        case .int(let int): self = Double(int)
        default:
            throw SerializableValue.Error.notInitializable(serializable)
        }
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
    public var float: Double? { try? Double(serializable: self) }
}

extension Bool: SerializableValueRepresentable {
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
    public var bool: Bool? { try? Bool(serializable: self) }
}

extension Date: SerializableValueRepresentable {
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
    
    public func date(_ decoder: DateDecodingStrategy = .deferredToDate) -> Date? {
        try? decoder.decode(self)
    }
}

extension Data: SerializableValueRepresentable {
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

extension String: SerializableValueRepresentable {
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
    public var string: String? { try? String(serializable: self) }
}

extension Array: SerializableValueConvertible where Element: SerializableValueConvertible {
    public var serializable: SerializableValue {
        .array(self.map{$0.serializable})
    }
}

extension Array: SerializableValueInitializable where Element: SerializableValueInitializable {
    public init(serializable: SerializableValue) throws {
        guard case .array(let array) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = try array.map{ try Element(serializable: $0) }
    }
}

extension Array where Element: SerializableValueConvertible {
    public func tryParse<E>(parser: @escaping (SerializableValue) throws -> E) -> [E]? {
        try? map { try parser($0.serializable) }
    }
    
    public func tryParse<E>(_ type: E.Type) -> [E]?
        where E: SerializableValueInitializable
    {
        tryParse { try E(serializable: $0) }
    }
    
    public func tryParse<E>() -> [E]?
        where E: SerializableValueInitializable
    {
        tryParse(E.self)
    }
    
    public func tryParse(
        _ parser: SerializableValue.DateDecodingStrategy = .deferredToDate
    ) -> [Date]? {
        tryParse { try parser.decode($0) }
    }
    
    public func tryParse(
        _ parser: SerializableValue.DataDecodingStrategy = .base64
    ) -> [Data]? {
        tryParse { try parser.decode($0) }
    }
}

extension SerializableValue: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = SerializableValueConvertible
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension SerializableValue {
    public var array: Array<SerializableValue>? { try? Array(serializable: self) }
}

extension Dictionary: SerializableValueInitializable where Key == String, Value: SerializableValueInitializable {
    public init(serializable: SerializableValue) throws {
        guard case .object(let obj) = serializable else {
            throw SerializableValue.Error.notInitializable(serializable)
        }
        self = try obj.mapValues { try Value(serializable: $0) }
    }
}

extension Dictionary: SerializableValueConvertible where Key == String, Value: SerializableValueConvertible {
    public var serializable: SerializableValue {
        .object(self.mapValues{$0.serializable})
    }
}

extension Dictionary where Key == String, Value: SerializableValueConvertible {
    public func tryParse<E>(parser: @escaping (SerializableValue) throws -> E) -> [String: E]? {
        try? mapValues { try parser($0.serializable) }
    }
    
    public func tryParse<E>(_ type: E.Type) -> [String: E]?
        where E: SerializableValueInitializable
    {
        tryParse { try E(serializable: $0) }
    }
    
    public func tryParse<E>() -> [String: E]?
        where E: SerializableValueInitializable
    {
        tryParse(E.self)
    }
    
    public func tryParse(
        _ parser: SerializableValue.DateDecodingStrategy = .deferredToDate
    ) -> [String: Date]? {
        tryParse { try parser.decode($0) }
    }
    
    public func tryParse(
        _ parser: SerializableValue.DataDecodingStrategy = .base64
    ) -> [String: Data]? {
        tryParse { try parser.decode($0) }
    }
}

extension SerializableValue: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = SerializableValueConvertible
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements) )
    }
}

extension SerializableValue {
    public var object: Dictionary<String, SerializableValue>? {
        try? Dictionary(serializable: self)
    }
}

extension Optional: SerializableValueConvertible where Wrapped: SerializableValueConvertible {
    public var serializable: SerializableValue {
        switch self {
        case .none: return .nil
        case .some(let val): return val.serializable
        }
    }
}
extension Optional: SerializableValueInitializable where Wrapped: SerializableValueInitializable {
    public init(serializable: SerializableValue) throws {
        switch serializable {
        case .nil: self = .none
        default: self = try .some(Wrapped(serializable: serializable))
        }
    }
}

extension Optional {
    public static var `nil`: SerializableValueRepresentable { SerializableValue.nil }
}

extension SerializableValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension SerializableValue {
    public var isNil: Bool { self == .nil }
}
