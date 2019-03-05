//
//  ParserCountLimitedTests.swift
//  ParserTests
//
//  Created by Josh Elkins on 2/6/19.
//  Copyright © 2019 Parser. All rights reserved.
//

import XCTest
import LastMile


struct TestArrays: Equatable {
    let arrayWithMin: [Int]
    let arrayWithMax: [Int]
    let arrayWithExact: [Int]
    let nonMandatoryArray: [Int]
}


extension TestArrays: APIDecodable {
    static let idKey: String? = nil

    init?(from decoder: APIDecoder) {
        let arrayWithMin = decoder["arrayWithMin"] --> CountLimited<[Int]>(min: 2, isMandatory: false)
        let arrayWithMax = decoder["arrayWithMax"] --> CountLimited<[Int]>(max: 2, isMandatory: true)
        let arrayWithExact = decoder["arrayWithExact"] --> CountLimited<[Int]>(exactly: 2, isMandatory: true)
        let nonMandatoryArray = decoder["nonmandatory"] --> CountLimited<[Int]>(exactly: 2, isMandatory: false)
        guard decoder.succeeded else { return nil }
        self.init(arrayWithMin: arrayWithMin!, arrayWithMax: arrayWithMax!, arrayWithExact: arrayWithExact!, nonMandatoryArray: nonMandatoryArray!)
    }
}


struct TestDicts: Equatable {
    let dictWithMin: [String: Int]
    let dictWithMax: [String: Int]
    let dictWithExact: [String: Int]
    let nonMandatoryDict: [String: Int]
}


extension TestDicts: APIDecodable {
    static var idKey: String? = nil

    init?(from decoder: APIDecoder) {
        let dictWithMin = decoder["dictWithMin"] --> CountLimited<[String: Int]>(min: 2, isMandatory: true)
        let dictWithMax = decoder["dictWithMax"] --> CountLimited<[String: Int]>(max: 2, isMandatory: true)
        let dictWithExact = decoder["dictWithExact"] --> CountLimited<[String: Int]>(exactly: 2, isMandatory: true)
        let nonMandatoryDict = decoder["nonmandatory"] --> CountLimited<[String: Int]>(exactly: 2, isMandatory: false)
        guard decoder.succeeded else { return nil }
        self.init(dictWithMin: dictWithMin!, dictWithMax: dictWithMax!, dictWithExact: dictWithExact!, nonMandatoryDict: nonMandatoryDict!)
    }
}


class ParserCountLimitedTests: XCTestCase {

    // MARK: - Array tests

    func testArraySucceedsWhenCountsAreSatisfied() {
        let jsonData = ["arrayWithMin": [1, 2], "arrayWithMax": [3, 4], "arrayWithExact": [5, 6], "nonmandatory": [7, 8]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestArrays.self)
        XCTAssertEqual(result.value, TestArrays(arrayWithMin: [1, 2], arrayWithMax: [3, 4], arrayWithExact: [5, 6], nonMandatoryArray: [7, 8]))
        XCTAssertEqual(result.errors, [])
    }

    func testArrayFailsWhenAMandatoryMinIsExceeded() {
        let jsonData = ["arrayWithMin": [1], "arrayWithMax": [3, 4], "arrayWithExact": [5, 6], "nonmandatory": [7, 8]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestArrays.self)
        XCTAssertEqual(result.value, TestArrays(arrayWithMin: [1], arrayWithMax: [3, 4], arrayWithExact: [5, 6], nonMandatoryArray: [7, 8]))
        XCTAssertEqual(result.errors, [APIDecodeError(path: ["root", "arrayWithMin"], minimum: 2, actual: 1)])
    }

    func testArrayFailsWhenBelowExactCount() {
        let jsonData = ["arrayWithMin": [1, 2], "arrayWithMax": [3, 4], "arrayWithExact": [5], "nonmandatory": [7, 8]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestArrays.self)
        XCTAssertNil(result.value)
        XCTAssertEqual(result.errors, [APIDecodeError(path: ["root", "arrayWithExact"], expected: 2, actual: 1)])
    }

    func testArrayFailsWhenAboveExactCount() {
        let jsonData = ["arrayWithMin": [1, 2], "arrayWithMax": [3, 4], "arrayWithExact": [5, 6, 7], "nonmandatory": [7, 8]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestArrays.self)
        XCTAssertNil(result.value)
        XCTAssertEqual(result.errors, [APIDecodeError(path: ["root", "arrayWithExact"], expected: 2, actual: 3)])
    }

    func testArraySucceedsWithErrorOnNonMandatoryFail() {
        let jsonData = ["arrayWithMin": [1, 2], "arrayWithMax": [3, 4], "arrayWithExact": [5, 6], "nonmandatory": [7, 8, 9]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestArrays.self)
        XCTAssertEqual(result.value, TestArrays(arrayWithMin: [1, 2], arrayWithMax: [3, 4], arrayWithExact: [5, 6], nonMandatoryArray: [7, 8, 9]))
        XCTAssertEqual(result.errors, [APIDecodeError(path: ["root", "nonmandatory"], expected: 2, actual: 3)])
    }

    // MARK: - Array tests

    func testDictSucceedsWhenCountsAreSatisfied() {
        let jsonData = ["dictWithMin": ["a": 1, "b": 2], "dictWithMax": ["c": 3, "d": 4], "dictWithExact": ["e": 5, "f": 6], "nonmandatory": ["g": 7, "h": 8]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestDicts.self)
        XCTAssertEqual(result.value, TestDicts(dictWithMin: ["a": 1, "b": 2], dictWithMax: ["c": 3, "d": 4], dictWithExact: ["e": 5, "f": 6], nonMandatoryDict: ["g": 7, "h": 8]))
        XCTAssertEqual(result.errors, [])
    }

    func testDictFailsWhenAMandatoryMinIsExceeded() {
        let jsonData = ["dictWithMin": ["a": 1], "dictWithMax": ["c": 3, "d": 4], "dictWithExact": ["e": 5, "f": 6], "nonmandatory": ["g": 7, "h": 8]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestDicts.self)
        XCTAssertNil(result.value)
        XCTAssertEqual(result.errors, [APIDecodeError(path: ["root", "dictWithMin"], minimum: 2, actual: 1)])
    }

    func testDictFailsWhenBelowExactCount() {
        let jsonData = ["dictWithMin": ["a": 1, "b": 2], "dictWithMax": ["c": 3, "d": 4], "dictWithExact": ["e": 5], "nonmandatory": ["g": 7, "h": 8]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestDicts.self)
        XCTAssertNil(result.value)
        XCTAssertEqual(result.errors, [APIDecodeError(path: ["root", "dictWithExact"], expected: 2, actual: 1)])
    }

    func testDictFailsWhenAboveExactCount() {
        let jsonData = ["dictWithMin": ["a": 1, "b": 2], "dictWithMax": ["c": 3, "d": 4], "dictWithExact": ["e": 5, "f": 6, "g": 7], "nonmandatory": ["g": 7, "h": 8]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestDicts.self)
        XCTAssertNil(result.value)
        XCTAssertEqual(result.errors, [APIDecodeError(path: ["root", "dictWithExact"], expected: 2, actual: 3)])
    }

    func testDictSucceedsWithErrorOnNonMandatoryFail() {
        let jsonData = ["dictWithMin": ["a": 1, "b": 2], "dictWithMax": ["c": 3, "d": 4], "dictWithExact": ["e": 5, "f": 6], "nonmandatory": ["g": 7, "h": 8, "i": 9]]
        let result = APIJSONObjectDecoder().decode(json: jsonData, to: TestDicts.self)
        XCTAssertEqual(result.value, TestDicts(dictWithMin: ["a": 1, "b": 2], dictWithMax: ["c": 3, "d": 4], dictWithExact: ["e": 5, "f": 6], nonMandatoryDict: ["g": 7, "h": 8, "i": 9]))
        XCTAssertEqual(result.errors, [APIDecodeError(path: ["root", "nonmandatory"], expected: 2, actual: 3)])
    }
}