//
//  APIDecoder.swift
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


public protocol APIDecoder: AnyObject {
    var node: JSONNode? { get }
    var codingKey: CodingKey { get }
    var codingPath: [CodingKey] { get }
    var key: APICodingKey { get }
    var path: [APICodingKey] { get }
    var errors: [APIDecodeError] { get set }
    subscript(key: String) -> APIDecoder { get }
    subscript(index: Int) -> APIDecoder { get }
    subscript(codingKey: CodingKey) -> APIDecoder { get }
    func superDecoder() -> APIDecoder
    func errorHoldingDecoder() -> APIDecoder
    func decodeRequired<DecodedType: APIDecodable>(_ type: DecodedType.Type, min: Int?, max: Int?, countsAreMandatory: Bool) -> DecodedType!
    func decodeOptional<DecodedType: APIDecodable>(_ type: DecodedType.Type, min: Int?, max: Int?, countsAreMandatory: Bool) -> DecodedType?
    func decodeRequired<DecodedType: Decodable>(swiftDecodable type: DecodedType.Type) -> DecodedType!
    func decodeOptional<DecodedType: Decodable>(swiftDecodable type: DecodedType.Type) -> DecodedType?
    var isJSONNull: Bool { get }
    func recordError(_ error: APIDecodeError)
    var succeeded: Bool { get set }
    var options: [String: Any] { get }
}


public extension APIDecoder {

    func decodeRequired<DecodedType: APIDecodable>(_ type: DecodedType.Type, min: Int? = nil, max: Int? = nil, countsAreMandatory: Bool = false) -> DecodedType! {
        return decodeRequired(type, min: min, max: max, countsAreMandatory: countsAreMandatory)
    }

    func decodeOptional<DecodedType: APIDecodable>(_ type: DecodedType.Type, min: Int? = nil, max: Int? = nil, countsAreMandatory: Bool = false) -> DecodedType? {
        return decodeOptional(type, min: min, max: max,  countsAreMandatory: countsAreMandatory)
    }
}


public enum APIDecodeOptions {
    public static let rootNodeNameKey = "APIDecodeOptions.rootNodeNameKey"
    public static let rawDataKey = "APIDecodeOptions.rawDataKey"
}
