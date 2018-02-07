//
//  ParseableSubStruct.swift
//  ParserTests
//
//  Created by Josh Elkins on 2/5/18.
//  Copyright © 2018 Parser. All rights reserved.
//

import Foundation
import Parser


struct ParseableSubStruct: Equatable {
    static var idKey: String? = "identifier"

    let identifier: String
}

extension ParseableSubStruct: Parseable {

    init?(parser: Parser) {
        let identifier = parser["identifier"].required(String.self)
        guard parser.succeeded else { return nil }
        self.init(identifier: identifier!)
    }
}


func ==(lhs: ParseableSubStruct, rhs: ParseableSubStruct) -> Bool {
    return lhs.identifier == rhs.identifier
}
