//
//  DataParserTests.swift
//  ParserTests
//
//  Created by Josh Elkins on 3/1/19.
//  Copyright © 2019 Parser. All rights reserved.
//

import XCTest
import Parser


struct TestObject: Parseable, Equatable {
    let name: String?

    init(name: String?) { self.name = name }

    init?(parser: Parser) {
        self.init(name: parser["name"] --> String?.self)
    }
}


class DataParserTests: XCTestCase {

    func testReturnsNilValueOnEmptyData() {
        let result = DataParser().parse(data: Data(), to: TestObject.self)
        XCTAssertNil(result.value)
    }

    func testReturnsNilValueOnInvalidJSON() {
        let data = "{\"name\":\"rumplestiltsk".data(using: .utf8)!
        let result = DataParser().parse(data: data, to: TestObject.self)
        XCTAssertNil(result.value)
    }

    func testParsesSuccessfully() {
        let data = "{\"name\":\"Joe Smith\"}".data(using: .utf8)!
        let result = DataParser().parse(data: data, to: TestObject.self)
        XCTAssertEqual(result.value, TestObject(name: "Joe Smith"))
        XCTAssertEqual(result.errors, [])
    }
}