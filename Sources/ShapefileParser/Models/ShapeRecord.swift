//
//  ShapeRecord.swift
//  
//
//  Created by Glenn Olsson on 2020-06-01.
//

import Foundation

class Point: Hashable {
	static func == (lhs: Point, rhs: Point) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.x)
		hasher.combine(self.y)
	}
	
	let x: Double
	let y: Double
	
	init(x: Double, y: Double) {
		self.x = x
		self.y = y
	}
}

protocol ShapeRecord: Hashable  {
	///Big endian, in 16bit words (2 byte, Half `Int`). Begins at 1
	var recordNumber: Int32 { get set }
	
	///Big endian, in 16bit words (2 byte, Half `Int`)
	var recordLength: Int32 { get set }
}

extension ShapeRecord {
	static func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.recordNumber == rhs.recordNumber
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.recordNumber)
	}
}
