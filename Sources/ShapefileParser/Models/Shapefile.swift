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

class ShapefileHeader {
	///Big endian, in 16bit words (2 byte, Half `Int`)
	fileprivate let fileLength: Int32

	///Little endian
	fileprivate let shapeType: ShapeType
	
	///Little endian, all in bounding rectangle
	fileprivate let xMin: Double
	fileprivate let xMax: Double
	fileprivate let yMin: Double
	fileprivate let yMax: Double
	fileprivate let zMin: Double
	fileprivate let zMax: Double
	fileprivate let mMin: Double
	fileprivate let mMax: Double
	
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
	}
	
	func getShapeType() -> ShapeType {
		return self.shapeType
	}
}

class Shapefile<Record: ShapeRecord> {
	
	private var header: ShapefileHeader
	private var records: [Record]

	init(header: ShapefileHeader){
		self.header = header
		self.records = []
	}
	
	func parseRecord(data: NSData, offset: Int) throws -> Record {
		return try Record.parse(data: data, offset: offset, mIsActive: self.getBoundingM() != (0, 0))
	}
	
	func getFileLength() -> Int32 {
		return header.fileLength.bigEndian
	}
	
	func getShapeType() -> ShapeType {
		return header.shapeType
	}
	
	///Returns (xMin, xMax)
	func getBoundingX() -> (Double, Double) {
		//Assume returned as little endian
		return (header.xMin, header.xMax)
	}
	
	///Returns (yMin, yMax)
	func getBoundingY() -> (Double, Double) {
		return (header.yMin, header.yMax)
	}
	
	///Returns (zMin, zMax)
	func getBoundingZ() -> (Double, Double) {
		return (header.zMin, header.zMax)
	}
	
	///Returns (mMin, Max)
	func getBoundingM() -> (Double, Double) {
		return (header.mMin, header.mMax)
	}
	
	func insert(record: Record) {
		self.records.append(record)
	}
	
	func getRecords() -> [Record] {
		return records
	}
}
