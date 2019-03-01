//
//  DataParser.swift
//  Parser
//
//  Created by Josh Elkins on 2/7/18.
//  Copyright © 2018 Parser. All rights reserved.
//

import Foundation


public class DataParser {

    public init() {}

    public func parse<ParsedType: Parseable>(data: Data, to type: ParsedType.Type, options: [String: Any] = [:]) -> ParseResult<ParsedType> {
        let json: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
        return JSONParser().parse(json: json, to: ParsedType.self, options: options)
    }
}
