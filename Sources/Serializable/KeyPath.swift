//
//  KeyPath.swift
//  Serializable
//
//  Created by Yehor Popovych on 30/08/2023.
//  Copyright © 2023 Tesseract Systems, Inc. All rights reserved.
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

public extension AnyValue {
    struct KeyPath: ExpressibleByStringLiteral, CustomStringConvertible {
        public let segments: [String]
        
        @inlinable public var isEmpty: Bool { segments.isEmpty }
        @inlinable public var path: String { segments.joined(separator: ".") }
        @inlinable public var description: String { path }
        
        public init(segments: [String]) {
            self.segments = segments
        }
        
        public init(_ string: String) {
            self.segments = string.components(separatedBy: ".")
        }
        
        public init(stringLiteral value: String) {
            self.init(value)
        }
        
        public func headAndTail() -> (head: String, tail: KeyPath)? {
            guard !isEmpty else { return nil }
            var tail = segments
            let head = tail.removeFirst()
            return (head, KeyPath(segments: tail))
        }
    }
    
    subscript(_ index: Int) -> Self? {
        switch self {
        case .object(let obj): return obj[String(index, radix: 10)]
        case .array(let arr):
            guard arr.indices.contains(index) else { return nil }
            return arr[index]
        default: return nil
        }
    }
    
    subscript(_ path: KeyPath) -> Self? {
        guard let hAt = path.headAndTail() else { return nil }
        switch self {
        case .object(let obj):
            return hAt.tail.isEmpty ? obj[hAt.head] : obj[hAt.head]?[hAt.tail]
        case .array(let arr):
            guard let index = Int(hAt.head, radix: 10), arr.indices.contains(index) else {
                return nil
            }
            return hAt.tail.isEmpty ? arr[index] : arr[index][hAt.tail]
        default: return nil
        }
    }
}
