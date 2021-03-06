//
//  APIJSONNodeDecoder.swift
//  LastMile
//
//  Copyright (c) 2019 Josh Elkins
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
//

import Foundation


public class APIJSONNodeDecoder {

    public init() {}

    public func decode<DecodedType: APIDecodable>(node: JSONNode?, to type: DecodedType.Type, options: [String: Any] = [:]) -> APIDecodeResult<DecodedType> {
        let decoder = APIJSONNodeDecoder.rootDecoder(node: node, options: options)
        let result = decoder.decodeRequired(DecodedType.self, min: nil, max: nil)
        return APIDecodeResult(value: result, errors: decoder.errors)
    }

    private static func rootDecoder(node: JSONNode?, options: [String: Any]) -> JSONAPIDecoder {
        let rootNodeName = options[APIDecodeOptions.rootNodeNameKey] as? String ?? "root"
        let rootNode = APICodingKey(hashKey: rootNodeName, swiftType: nil)
        return JSONAPIDecoder(codingKey: rootNode, node: node, parent: nil, errorTarget: nil, options: options)
    }
}
