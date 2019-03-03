//
//  ParseResult.swift
//  Parser
//
//  Created by Josh Elkins on 2/27/19.
//  Copyright © 2019 Parser. All rights reserved.
//

import Foundation


public struct ParseResult<ParsedValue: Parseable> {
    public let value: ParsedValue?
    public let errors: [ParseError]
}
