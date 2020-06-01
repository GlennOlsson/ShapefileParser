//
//  Shapefile.swift
//  
//
//  Created by Glenn Olsson on 2020-06-01.
//

import Foundation

/// For simplicity, use the static `create()` function. If the init mthod is called, be sure to convert
/// the integer to little endian first
enum ShapeType: Int32 {
	case null_Shape		= 0
	case point			= 1
	case polyLine		= 3
	case polygon		= 5
	case multiPoint		= 8
	case pointZ			= 11
	case polyLineZ		= 13
	case polygonZ		= 15
	case multiPointZ	= 18
	case pointM			= 21
	case polyLineM		= 23
	case polygonM		= 25
	case multiPointM	= 28
	case multiPatch		= 31
	
	static func create(_ value: Int32) -> ShapeType? {
		return ShapeType(rawValue: value.littleEndian)
	}
}

extension Double {
	var littleEndian: Double {
		get {
			let bitpattern = self.bitPattern.littleEndian
			return Double(bitPattern: bitpattern)
		}
	}
}

class Shapefile {
	///Big endian, in 16bit words (2 byte, Half `Int`)
	private let fileLength: Int32

	///Little endian
	private let shapeType: ShapeType
	
	///Little endian, all in bounding rectangle
	private let xMin: Double
	private let xMax: Double
	private let yMin: Double
	private let yMax: Double
	private let zMin: Double
	private let zMax: Double
	private let mMin: Double
	private let mMax: Double
	
	private var records: [ShapeRecord]
	
	init(fileLength: Int32, shapeType: ShapeType, xMin: Double, xMax: Double, yMin: Double, yMax: Double, zMin: Double, zMax: Double, mMin: Double, mMax: Double) {
		
		self.fileLength = fileLength.bigEndian
		self.shapeType = shapeType
		
		self.xMin = xMin.littleEndian
		self.xMax = xMax.littleEndian
		self.yMin = yMin.littleEndian
		self.yMax = yMax.littleEndian
		self.zMin = zMin.littleEndian
		self.zMax = zMax.littleEndian
		self.mMin = mMin.littleEndian
		self.mMax = mMax.littleEndian
		
		self.records = []
	}
	
	func getFileLength() -> Int32 {
		return fileLength.bigEndian
	}
	
	func getShapeType() -> ShapeType {
		return shapeType
	}
	
	///Returns (xMin, xMax)
	func getBoundingX() -> (Double, Double) {
		//Assume returned as little endian
		return (xMin, xMax)
	}
	
	///Returns (yMin, yMax)
	func getBoundingY() -> (Double, Double) {
		return (yMin, yMax)
	}
	
	///Returns (zMin, zMax)
	func getBoundingZ() -> (Double, Double) {
		return (zMin, zMax)
	}
	
	///Returns (mMin, Max)
	func getBoundingM() -> (Double, Double) {
		return (mMin, mMax)
	}
	
	func insert(record: ShapeRecord) {
		self.records.append(record)
	}
	
	func getRecords() -> [ShapeRecord] {
		return records
	}
}
