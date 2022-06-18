//
//  DecodableTests.swift
//  LastMile
//
//  Copyright (c) 2018 Josh Elkins
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import XCTest
import LastMile


fileprivate struct TestContainer<Value: Decodable & Equatable>: APIDecodable  {
    let value: Value

    init?(from decoder: APIDecoder) {
        guard let v = decoder.decodeRequired(swiftDecodable: Value.self) else { return nil }
        value = v
    }
}


class DecodableTests: XCTestCase {

    func testDecodesANewInstance() {

        struct SampleCodableData: Codable, Equatable {
            let id: Int
            let name: String
            let address: String
            let intOrNot: Int?
            let stringOrNot: String?
            let itsTrue: Bool
            let itsFalse: Bool
            let boolOrNot: Bool?
            let numbahs: [Double]
            let valyews: [String: UInt8]
        }

        let jsonObject: [String : Any] = [
            "id": 123,
            "name": "xyz",
            "address": "abc",
            "intOrNot": NSNull(),
            "itsTrue": true,
            "itsFalse": false,
            "numbahs": [8, 6, 7, 5, 3, 0, 9],
            "valyews": ["wun": 1, "tyew": 2, "big": 255]
        ]
        let data = try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
        compareResults(data: data, outputType: SampleCodableData.self)
    }

    func testDoesNotDecode1ToBool() {

        struct HasABool: Decodable, Equatable {
            let boolValue: Bool
        }

        let data = try! JSONSerialization.data(withJSONObject: ["boolValue": 1], options: [])
        compareResults(data: data, outputType: HasABool.self)
    }

    func testDoesNotDecodeTrueTo1() {

        struct HasAnInt: Decodable, Equatable {
            let intValue: Int
        }

        let data = try! JSONSerialization.data(withJSONObject: ["intValue": true], options: [])
        compareResults(data: data, outputType: HasAnInt.self)
    }

    func testDoesNotDecode1Point0To1() {

        struct HasAnInt: Decodable, Equatable {
            let intValue: Int
        }

        let data = try! JSONSerialization.data(withJSONObject: ["intValue": 1.0], options: [])
        compareResults(data: data, outputType: HasAnInt.self)
    }

    func testDecodesAClassThatInherits() {
        let original = SubClass(id: 567, name: "jerry")
        let data = try! JSONEncoder().encode(original)
        compareResults(data: data, outputType: SubClass.self)
    }

    func testDecodesAnArrayOfAClassThatInherits() {
        let original = [SubClass(id: 567, name: "jerry"), SubClass(id: 345, name: "bill")]
        let data = try! JSONEncoder().encode(original)
        compareResults(data: data, outputType: [SubClass].self)
    }

    func testDecodesADictOfAClassThatInherits() {
        let original = ["guy": SubClass(id: 567, name: "jerry"), "dude": SubClass(id: 345, name: "bill")]
        let data = try! JSONEncoder().encode(original)
        compareResults(data: data, outputType: [String: SubClass].self)
    }

    private func compareResults<T: Decodable & Equatable>(data: Data, outputType: T.Type) {
        let swiftResult = decode(T.self, from: data, using: JSONDecoder())
        let ourResult = decode(T.self, from: data, using: APIDataDecoder())
        XCTAssertEqual(swiftResult, ourResult)
    }

    private func decode<T: Decodable & Equatable>(_ type: T.Type, from data: Data, using decoder: DecodesJSONDataToEquatable) -> DecodeResult<T> {
        do {
            let result = try decoder.decode(T.self, from: data)
            return DecodeResult.success(result)
        } catch let error as DecodingError {
            return DecodeResult.error(error)
        } catch let error as APIDecodeError {
            if case APIDecodeErrorReason.swiftDecodingError(let decodeError) = error.reason {
                return .error(decodeError)
            }
            XCTFail("Unexpected error: \(error)")
            fatalError()
        } catch let error {
            XCTFail("Unexpected error: \(error)")
            fatalError()
        }
    }
}


enum DecodeResult<T: Decodable & Equatable>: Equatable {
    case success(T?)
    case error(DecodingError)
}


fileprivate protocol DecodesJSONDataToEquatable {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable & Equatable
}

extension JSONDecoder: DecodesJSONDataToEquatable {}

extension APIDataDecoder: DecodesJSONDataToEquatable {

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable & Equatable {
        let result = decode(data: data, to: TestContainer<T>.self)
        if let container = result.value {
            return container.value
        } else {
            throw result.errors.last!
        }
    }
}


class Parent: Codable {
    let id: Int
    init(id: Int) { self.id = id }
}

class SubClass: Parent, Equatable {
    let name: String

    enum CodingKeys: String, CodingKey { case name }
    init(id: Int, name: String) { self.name = name; super.init(id: id) }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        try super.init(from: container.superDecoder())
    }
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try super.encode(to: container.superEncoder())
    }
    static func == (lhs: SubClass, rhs: SubClass) -> Bool { return lhs.id == rhs.id && lhs.name == rhs.name }
}
