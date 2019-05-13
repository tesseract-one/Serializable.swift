//
//  FoundationExtensions.swift
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

private let DATE_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return formatter
}()

extension Int: SerializableProtocol {
    public init(serializable: SerializableValue) throws {
        guard case .int(let int) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = int
    }
    public var serializable: SerializableValue { return .int(self) }
}

extension SerializableValue: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension SerializableValue {
    public var int: Int? {
        switch self {
        case .int(let int): return int
        case .float(let float): return Int(float)
        default: return nil
        }
    }
}

extension Double: SerializableProtocol {
    public init(serializable: SerializableValue) throws {
        guard case .float(let num) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = num
    }
    public var serializable: SerializableValue { return .float(self) }
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

extension Bool: SerializableProtocol {
    public init(serializable: SerializableValue) throws {
        guard case .bool(let bool) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = bool
    }
    public var serializable: SerializableValue { return .bool(self) }
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

extension Date: SerializableProtocol {
    public init(serializable: SerializableValue) throws {
        switch serializable {
        case .string(let str):
            guard let date = DATE_FORMATTER.date(from: str) else {
                throw SerializableValue.Error.notInitializable(serializable)
            }
            self = date
        case .float(let num):
            self = Date(timeIntervalSince1970: num)
        case .int(let int):
            self = Date(timeIntervalSince1970: Double(int))
        default:
            throw SerializableValue.Error.notInitializable(serializable)
        }
    }
    public var serializable: SerializableValue { return .string(DATE_FORMATTER.string(from: self)) }
}

extension SerializableValue {
    public var date: Date? {
        return try? Date(serializable: self)
    }
}

extension Data: SerializableProtocol {
    public init(serializable: SerializableValue) throws {
        switch serializable {
        case .string(let str):
            guard let data = Data(base64Encoded: str) else {
                throw SerializableValue.Error.notInitializable(serializable)
            }
            self = data
        default:
            throw SerializableValue.Error.notInitializable(serializable)
        }
    }
    public var serializable: SerializableValue { return .string(self.base64EncodedString()) }
}

extension SerializableValue {
    public var data: Data? {
        return try? Data(serializable: self)
    }
}

extension String: SerializableProtocol {
    public init(serializable: SerializableValue) throws {
        guard case .string(let str) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = str
    }
    public var serializable: SerializableValue { return .string(self) }
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
    public var serializable: SerializableValue { return .array(self.map{$0.serializable}) }
}

extension Array: SerializableValueDecodable where Element: SerializableValueDecodable {
    public init(serializable: SerializableValue) throws {
        guard case .array(let array) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
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
        guard case .object(let obj) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = try obj.mapValues { try Value(serializable: $0) }
    }
}

extension Dictionary: SerializableValueEncodable where Key == String, Value: SerializableValueEncodable {
    public var serializable: SerializableValue {
        return .object(self.mapValues { $0.serializable })
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
    public static var `nil`: SerializableProtocol {
        return SerializableValue.nil
    }
}

extension SerializableValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension SerializableValue {
    public var isNil: Bool {
        return self == .nil
    }
}
