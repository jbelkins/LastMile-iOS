//
//  DecodableStruct.swift
//  ParserTests
//
//  Created by Josh Elkins on 2/12/18.
//  Copyright © 2018 Parser. All rights reserved.
//

import Foundation
import LastMile


struct SwiftDecodableStruct: Swift.Decodable, Equatable {
    let id: Int
    let name: String
    let notes: String?
}
