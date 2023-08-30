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

extension Int64: AnyValueRepresentable {
    public init(anyValue: AnyValue) throws {
        guard case .int(let int) = anyValue else {
            throw AnyValue.NotInitializable(type: "Int64", from: anyValue)
        }
        self = int
    }
    
    public var anyValue: AnyValue { .int(self) }
}

extension AnyValue: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int64

    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension AnyValue {
    public var int: Int64? { try? Int64(anyValue: self) }
}

extension Double: AnyValueRepresentable {
    public init(anyValue: AnyValue) throws {
        switch anyValue {
        case .float(let num): self = num
        case .int(let int): self = Double(int)
        default:
            throw AnyValue.NotInitializable(type: "Double", from: anyValue)
        }
    }
    
    public var anyValue: AnyValue { .float(self) }
}

extension AnyValue: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .float(value)
    }
}

extension AnyValue {
    public var float: Double? { try? Double(anyValue: self) }
}

extension Bool: AnyValueRepresentable {
    public init(anyValue: AnyValue) throws {
        guard case .bool(let bool) = anyValue else {
            throw AnyValue.NotInitializable(type: "Bool", from: anyValue)
        }
        self = bool
    }
    
    public var anyValue: AnyValue { .bool(self) }
}

extension AnyValue: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension AnyValue {
    public var bool: Bool? { try? Bool(anyValue: self) }
}

extension Date: AnyValueRepresentable {
    public init(anyValue: AnyValue) throws {
        guard case .date(let date) = anyValue else {
            throw AnyValue.NotInitializable(type: "Date", from: anyValue)
        }
        self = date
    }
    
    public var anyValue: AnyValue { .date(self) }
}

extension AnyValue {
    public var date: Date? { date() }
    
    public func date(_ decoder: DateDecodingStrategy = .deferredToDate) -> Date? {
        try? decoder.decode(self)
    }
}

extension Data: AnyValueRepresentable {
    public init(anyValue: AnyValue) throws {
        guard case .bytes(let data) = anyValue else {
            throw AnyValue.NotInitializable(type: "Data", from: anyValue)
        }
        self = data
    }
    
    public var anyValue: AnyValue { .bytes(self) }
}

extension AnyValue {
    public var bytes: Data? { bytes() }
    
    public func bytes(_ decoder: DataDecodingStrategy = .base64) -> Data? {
        try? decoder.decode(self)
    }
}

extension String: AnyValueRepresentable {
    public init(anyValue: AnyValue) throws {
        guard case .string(let str) = anyValue else {
            throw AnyValue.NotInitializable(type: "String", from: anyValue)
        }
        self = str
    }
    
    public var anyValue: AnyValue { .string(self) }
}

extension AnyValue: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension AnyValue {
    public var string: String? { try? String(anyValue: self) }
}

extension Array: AnyValueConvertible where Element: AnyValueConvertible {
    public var anyValue: AnyValue {
        .array(self.map{$0.anyValue})
    }
}

extension Array: AnyValueInitializable where Element: AnyValueInitializable {
    public init(anyValue: AnyValue) throws {
        guard case .array(let array) = anyValue else {
            throw AnyValue.NotInitializable(type: "Array", from: anyValue)
        }
        self = try array.map{ try Element(anyValue: $0) }
    }
}

extension Array where Element: AnyValueConvertible {
    public func tryParse<E>(parser: @escaping (AnyValue) throws -> E) -> [E]? {
        try? map { try parser($0.anyValue) }
    }
    
    public func tryParse<E>(_ type: E.Type) -> [E]?
        where E: AnyValueInitializable
    {
        tryParse { try E(anyValue: $0) }
    }
    
    public func tryParse<E>() -> [E]?
        where E: AnyValueInitializable
    {
        tryParse(E.self)
    }
    
    public func tryParse(
        _ parser: AnyValue.DateDecodingStrategy = .deferredToDate
    ) -> [Date]? {
        tryParse { try parser.decode($0) }
    }
    
    public func tryParse(
        _ parser: AnyValue.DataDecodingStrategy = .base64
    ) -> [Data]? {
        tryParse { try parser.decode($0) }
    }
}

extension AnyValue: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = AnyValueConvertible
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension AnyValue {
    public var array: Array<Self>? { try? Array(anyValue: self) }
}

extension Dictionary: AnyValueInitializable where Key == String, Value: AnyValueInitializable {
    public init(anyValue: AnyValue) throws {
        guard case .object(let obj) = anyValue else {
            throw AnyValue.NotInitializable(type: "Dictionary", from: anyValue)
        }
        self = try obj.mapValues { try Value(anyValue: $0) }
    }
}

extension Dictionary: AnyValueConvertible where Key == String, Value: AnyValueConvertible {
    public var anyValue: AnyValue {
        .object(self.mapValues{$0.anyValue})
    }
}

extension Dictionary where Key == String, Value: AnyValueConvertible {
    public func tryParse<E>(parser: @escaping (AnyValue) throws -> E) -> [String: E]? {
        try? mapValues { try parser($0.anyValue) }
    }
    
    public func tryParse<E>(_ type: E.Type) -> [String: E]?
        where E: AnyValueInitializable
    {
        tryParse { try E(anyValue: $0) }
    }
    
    public func tryParse<E>() -> [String: E]?
        where E: AnyValueInitializable
    {
        tryParse(E.self)
    }
    
    public func tryParse(
        _ parser: AnyValue.DateDecodingStrategy = .deferredToDate
    ) -> [String: Date]? {
        tryParse { try parser.decode($0) }
    }
    
    public func tryParse(
        _ parser: AnyValue.DataDecodingStrategy = .base64
    ) -> [String: Data]? {
        tryParse { try parser.decode($0) }
    }
}

extension AnyValue: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = AnyValueConvertible
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements) )
    }
}

extension AnyValue {
    public var object: Dictionary<String, Self>? {
        try? Dictionary(anyValue: self)
    }
}

extension Optional: AnyValueConvertible where Wrapped: AnyValueConvertible {
    public var anyValue: AnyValue {
        switch self {
        case .none: return .nil
        case .some(let val): return val.anyValue
        }
    }
}
extension Optional: AnyValueInitializable where Wrapped: AnyValueInitializable {
    public init(anyValue: AnyValue) throws {
        switch anyValue {
        case .nil: self = .none
        default: self = try .some(Wrapped(anyValue: anyValue))
        }
    }
}

extension Optional {
    public static var `nil`: AnyValueRepresentable { AnyValue.nil }
}

extension AnyValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension AnyValue {
    public var isNil: Bool { self == .nil }
}
