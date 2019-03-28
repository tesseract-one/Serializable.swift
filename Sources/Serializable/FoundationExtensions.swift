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
    public init(_ serializable: SerializableValue) throws {
        guard case .int(let int) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = int
    }
    public var serializable: SerializableValue { return .int(self) }
}
extension SerializableValueDecodable {
    public var int: Int? {
        switch self {
        case let val as SerializableValue:
            guard case .int(let int) = val else { return nil }
            return int
        case let int as Int: return int
        default: return nil
        }
    }
}

extension Double: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .float(let num) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = num
    }
    public var serializable: SerializableValue { return .float(self) }
}
extension SerializableValueDecodable {
    public var float: Double? {
        switch self {
        case let val as SerializableValue:
            guard case .float(let num) = val else { return nil }
            return num
        case let num as Double: return num
        default: return nil
        }
    }
}

extension Bool: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .bool(let bool) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = bool
    }
    public var serializable: SerializableValue { return .bool(self) }
}
extension SerializableValueDecodable {
    public var bool: Bool? {
        switch self {
        case let val as SerializableValue:
            guard case .bool(let bool) = val else { return nil }
            return bool
        case let bool as Bool: return bool
        default: return nil
        }
    }
}

extension Date: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
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
extension SerializableValueDecodable {
    public var date: Date? {
        switch self {
        case let val as SerializableValue:
            return try? Date(val)
        case let str as String:
            return DATE_FORMATTER.date(from: str)
        case let num as Double:
            return Date(timeIntervalSince1970: num)
        case let int as Int:
            return Date(timeIntervalSince1970: Double(int))
        case let date as Date: return date
        default: return nil
        }
    }
}

extension Data: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
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
extension SerializableValueDecodable {
    public var data: Data? {
        switch self {
        case let val as SerializableValue:
            return try? Data(val)
        case let str as String:
            return Data(base64Encoded: str)
        case let data as Data: return data
        default: return nil
        }
    }
}

extension String: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .string(let str) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = str
    }
    public var serializable: SerializableValue { return .string(self) }
}
extension SerializableValueDecodable {
    public var string: String? {
        switch self {
        case let val as SerializableValue:
            guard case .string(let str) = val else { return nil }
            return str
        case let str as String: return str
        default: return nil
        }
    }
}

extension Array: SerializableValueEncodable where Element: SerializableValueEncodable {
    public var serializable: SerializableValue { return .array(self.map{$0.serializable}) }
}
extension Array: SerializableValueDecodable where Element: SerializableValueDecodable {
    public init(_ serializable: SerializableValue) throws {
        guard case .array(let array) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = try array.map{ try Element($0) }
    }
}
extension SerializableValueDecodable {
    public var array: Array<SerializableValue>? {
        switch self {
        case let val as SerializableValue:
            guard case .array(let array) = val else { return nil }
            return array
        case let array as Array<SerializableValue>: return array
        case let array as Array<SerializableProtocol>: return array.map{$0.serializable}
        default: return nil
        }
    }
}

extension Dictionary: SerializableValueDecodable where Key == String, Value: SerializableValueDecodable {
    public init(_ serializable: SerializableValue) throws {
        guard case .object(let obj) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = try obj.mapValues { try Value($0) }
    }
}

extension Dictionary: SerializableValueEncodable where Key == String, Value: SerializableValueEncodable {
    public var serializable: SerializableValue {
        return .object(self.mapValues { $0.serializable })
    }
}

extension SerializableValueDecodable {
    public var object: Dictionary<String, SerializableValue>? {
        switch self {
        case let val as SerializableValue:
            guard case .object(let obj) = val else { return nil }
            return obj
        case let object as Dictionary<String, SerializableValue>: return object
        case let dict as Dictionary<String, SerializableProtocol>: return dict.mapValues { $0.serializable }
        default: return nil
        }
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
    public init(_ serializable: SerializableValue) throws {
        switch serializable {
        case .nil: self = .none
        default: self = try .some(Wrapped(serializable))
        }
    }
}

extension Optional {
    public static var `nil`: SerializableProtocol {
        return SerializableValue.nil
    }
}
