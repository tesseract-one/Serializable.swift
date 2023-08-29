# Serializable

![🐧 linux: ready](https://img.shields.io/badge/%F0%9F%90%A7%20linux-ready-red.svg)
[![GitHub license](https://img.shields.io/badge/license-Apache%202.0-lightgrey.svg)](https://raw.githubusercontent.com/tesseract-one/Serializable.swift/master/LICENSE)
[![Build Status](https://github.com/tesseract-one/Serializable.swift/workflows/Build%20&%20Tests/badge.svg?branch=main)](https://github.com/tesseract-one/Serializable.swift/actions/workflows/build.yml?query=branch%3Amain)
[![GitHub release](https://img.shields.io/github/release/tesseract-one/Serializable.swift.svg)](https://github.com/tesseract-one/Serializable.swift/releases)
[![CocoaPods version](https://img.shields.io/cocoapods/v/Serializable.swift.svg)](https://cocoapods.org/pods/Serializable.swift)
![Platform OS X | iOS | tvOS | watchOS | Linux](https://img.shields.io/badge/platform-Linux%20%7C%20OS%20X%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-orange.svg)

## Dynamic value for Swift Codable

## Goals

This library allows encoding and decoding of dynamic data structures via Swift Codable.

## Supported types

* Dictionary
* Array
* Bool
* Float(Double)
* Int
* String
* null

### Additional types

`Date` and `Data` can be converted in runtime from the `String` type.

## Getting started

### Installation

#### [Package Manager](https://swift.org/package-manager/)

Add the following dependency to your [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#define-dependencies):

```swift
.package(url: "https://github.com/tesseract-one/Serializable.swift.git", from: "0.3.0")
```

Run `swift build` and build your app.

#### [CocoaPods](http://cocoapods.org/)

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'Serializable.swift' '~> 0.3'
```

Then run `pod install`.

#### Manually
1. Download and drop `Sources/Serializable` folder in your project.  
2. Congratulations! 

### Examples

#### JSON parsing

```swift
import Foundation
import Serializable

let json = """
{
  "message": "Hello, World!"
}
""".data(using: .utf8)!

let value = try! JSONDecoder().decode(Value.self, from: json)

print("Message:", value.object!["message"].string!)
```

## Author

 - [Tesseract Systems, Inc.](mailto:info@tesseract.one)
   ([@tesseract_one](https://twitter.com/tesseract_one))

## License

Serializable.swift is available under the Apache 2.0 license. See [the LICENSE file](./LICENSE) for more information.
