//
//  ShapeRecord.swift
//  
//
//  Created by Glenn Olsson on 2020-06-01.
//

import Foundation

class ShapeRecord: Hashable {
	static func == (lhs: ShapeRecord, rhs: ShapeRecord) -> Bool {
		return lhs.recordNumber == rhs.recordNumber
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.recordNumber)
	}
	
	///Big endian, in 16bit words (2 byte, Half `Int`). Begins at 1
	private let recordNumber: Int
	
	///Big endian, in 16bit words (2 byte, Half `Int`)
	private let recordLength: Int
	
	init(recordNumber: Int, recordLength: Int) {
		self.recordNumber = recordNumber.bigEndian
		self.recordLength = recordLength.bigEndian
	}
}
