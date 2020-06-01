//
//  ShapeParserError.swift
//  
//
//  Created by Glenn Olsson on 2020-06-01.
//

import Foundation

enum ShapeParserError: String, Error {
	case badShapeType = "Bad shape type"
	case generalParseError = "General parse error "
	case noSuchFile = "No file with path"
	case badFileCode = "Bad file code"
}
