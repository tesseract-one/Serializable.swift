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

extension Int64: ValueRepresentable {
    public init(serializable: Value) throws {
        guard case .int(let int) = serializable else {
            throw Value.Error.notInitializable(serializable)
        }
        self = int
    }
    
    public var serializable: Value { .int(self) }
}

extension Value: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int64

    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension Value {
    public var int: Int64? { try? Int64(serializable: self) }
}

extension Double: ValueRepresentable {
    public init(serializable: Value) throws {
        switch serializable {
        case .float(let num): self = num
        case .int(let int): self = Double(int)
        default:
            throw Value.Error.notInitializable(serializable)
        }
    }
    
    public var serializable: Value { .float(self) }
}

extension Value: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .float(value)
    }
}

extension Value {
    public var float: Double? { try? Double(serializable: self) }
}

extension Bool: ValueRepresentable {
    public init(serializable: Value) throws {
        guard case .bool(let bool) = serializable else {
            throw Value.Error.notInitializable(serializable)
        }
        self = bool
    }
    
    public var serializable: Value { .bool(self) }
}

extension Value: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension Value {
    public var bool: Bool? { try? Bool(serializable: self) }
}

extension Date: ValueRepresentable {
    public init(serializable: Value) throws {
        guard case .date(let date) = serializable else {
            throw Value.Error.notInitializable(serializable)
        }
        self = date
    }
    
    public var serializable: Value { .date(self) }
}

extension Value {
    public var date: Date? { date() }
    
    public func date(_ decoder: DateDecodingStrategy = .deferredToDate) -> Date? {
        try? decoder.decode(self)
    }
}

extension Data: ValueRepresentable {
    public init(serializable: Value) throws {
        guard case .bytes(let data) = serializable else {
            throw Value.Error.notInitializable(serializable)
        }
        self = data
    }
    
    public var serializable: Value { .bytes(self) }
}

extension Value {
    public var bytes: Data? { bytes() }
    
    public func bytes(_ decoder: DataDecodingStrategy = .base64) -> Data? {
        try? decoder.decode(self)
    }
}

extension String: ValueRepresentable {
    public init(serializable: Value) throws {
        guard case .string(let str) = serializable else {
            throw Value.Error.notInitializable(serializable)
        }
        self = str
    }
    
    public var serializable: Value { .string(self) }
}

extension Value: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension Value {
    public var string: String? { try? String(serializable: self) }
}

extension Array: ValueConvertible where Element: ValueConvertible {
    public var serializable: Value {
        .array(self.map{$0.serializable})
    }
}

extension Array: ValueInitializable where Element: ValueInitializable {
    public init(serializable: Value) throws {
        guard case .array(let array) = serializable else {
            throw Value.Error.notInitializable(serializable)
        }
        self = try array.map{ try Element(serializable: $0) }
    }
}

extension Array where Element: ValueConvertible {
    public func tryParse<E>(parser: @escaping (Value) throws -> E) -> [E]? {
        try? map { try parser($0.serializable) }
    }
    
    public func tryParse<E>(_ type: E.Type) -> [E]?
        where E: ValueInitializable
    {
        tryParse { try E(serializable: $0) }
    }
    
    public func tryParse<E>() -> [E]?
        where E: ValueInitializable
    {
        tryParse(E.self)
    }
    
    public func tryParse(
        _ parser: Value.DateDecodingStrategy = .deferredToDate
    ) -> [Date]? {
        tryParse { try parser.decode($0) }
    }
    
    public func tryParse(
        _ parser: Value.DataDecodingStrategy = .base64
    ) -> [Data]? {
        tryParse { try parser.decode($0) }
    }
}

extension Value: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = ValueConvertible
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension Value {
    public var array: Array<Self>? { try? Array(serializable: self) }
}

extension Dictionary: ValueInitializable where Key == String, Value: ValueInitializable {
    public init(serializable: Serializable.Value) throws {
        guard case .object(let obj) = serializable else {
            throw Serializable.Value.Error.notInitializable(serializable)
        }
        self = try obj.mapValues { try Value(serializable: $0) }
    }
}

extension Dictionary: ValueConvertible where Key == String, Value: ValueConvertible {
    public var serializable: Serializable.Value {
        .object(self.mapValues{$0.serializable})
    }
}

extension Dictionary where Key == String, Value: ValueConvertible {
    public func tryParse<E>(parser: @escaping (Serializable.Value) throws -> E) -> [String: E]? {
        try? mapValues { try parser($0.serializable) }
    }
    
    public func tryParse<E>(_ type: E.Type) -> [String: E]?
        where E: ValueInitializable
    {
        tryParse { try E(serializable: $0) }
    }
    
    public func tryParse<E>() -> [String: E]?
        where E: ValueInitializable
    {
        tryParse(E.self)
    }
    
    public func tryParse(
        _ parser: Serializable.Value.DateDecodingStrategy = .deferredToDate
    ) -> [String: Date]? {
        tryParse { try parser.decode($0) }
    }
    
    public func tryParse(
        _ parser: Serializable.Value.DataDecodingStrategy = .base64
    ) -> [String: Data]? {
        tryParse { try parser.decode($0) }
    }
}

extension Value: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = ValueConvertible
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements) )
    }
}

extension Value {
    public var object: Dictionary<String, Self>? {
        try? Dictionary(serializable: self)
    }
}

extension Optional: ValueConvertible where Wrapped: ValueConvertible {
    public var serializable: Value {
        switch self {
        case .none: return .nil
        case .some(let val): return val.serializable
        }
    }
}
extension Optional: ValueInitializable where Wrapped: ValueInitializable {
    public init(serializable: Value) throws {
        switch serializable {
        case .nil: self = .none
        default: self = try .some(Wrapped(serializable: serializable))
        }
    }
}

extension Optional {
    public static var `nil`: ValueRepresentable { Value.nil }
}

extension Value: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension Value {
    public var isNil: Bool { self == .nil }
}
