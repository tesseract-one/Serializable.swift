//
//  Subscripts.swift
//  Serializable
//
//  Created by Yehor Popovych on 30/08/2023.
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

public extension AnyValue {
    subscript(_ index: Int) -> Self? {
        get {
            switch self {
            case .array(let arr): return arr.get(index: index)
            default: return nil
            }
        }
        set {
            switch self {
            case .array(var arr):
                arr.set(element: newValue, at: index)
                self = .array(arr)
            default: return
            }
        }
    }
    
    subscript(_ key: String) -> Self? {
        get {
            switch self {
            case .object(let dict): return dict[key]
            case .array(let arr):
                guard let index = Int(key) else { return nil }
                return arr.get(index: index)
            default: return nil
            }
        }
        set {
            switch self {
            case .object(var dict):
                dict[key] = newValue
                self = .object(dict)
            case .array(var arr):
                guard let index = Int(key) else { return }
                arr.set(element: newValue, at: index)
                self = .array(arr)
            default: return
            }
        }
    }
}

private extension Array where Element == AnyValue {
    func get(index: Int) -> Element? {
        let index = index >= 0 ? index : endIndex + index
        guard indices.contains(index) else { return nil }
        return self[index]
    }
    
    mutating func set(element: Element?, at index: Int) {
        let index = index >= 0 ? index : endIndex + index
        guard index >= 0 else { return }
        if let value = element {
            if indices.contains(index) { self[index] = value }
            else {
                for _ in 0..<(index - endIndex) { append(.nil) }
                append(value)
            }
        } else {
            if indices.contains(index) { remove(at: index) }
        }
    }
}
