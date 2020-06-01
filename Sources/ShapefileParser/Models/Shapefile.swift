//
//  Shapefile.swift
//  
//
//  Created by Glenn Olsson on 2020-06-01.
//

import Foundation

/// For simplicity, use the static `create()` function. If the init mthod is called, be sure to convert
/// the integer to little endian first
enum ShapeType: Int {
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
	
	static func create(_ value: Int) -> ShapeType? {
		return ShapeType(rawValue: value.littleEndian)
	}
}

class Shapefile {
	///Big endian
	private let fileLength: Int

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
	
	init(fileLength: Int, shapeType: ShapeType, xMin: Double, xMax: Double, yMin: Double, yMax: Double, zMin: Double, zMax: Double, mMin: Double, mMax: Double) {
		
		self.fileLength = fileLength.bigEndian
		self.shapeType = shapeType
		
		self.xMin = littleEndian(of: xMin)
		self.xMax = littleEndian(of: xMax)
		self.yMin = littleEndian(of: yMin)
		self.yMax = littleEndian(of: yMax)
		self.zMin = littleEndian(of: zMin)
		self.zMax = littleEndian(of: zMax)
		self.mMin = littleEndian(of: mMin)
		self.mMax = littleEndian(of: mMax)
	}
	
	private func littleEndian(of value: Double) -> Double {
		let bitpattern = value.bitPattern.littleEndian
		return Double(bitPattern: bitpattern)
	}
	
	func getFileLength() -> Int{
		return fileLength
	}
	
	func getShapeType: ShapeType {
		return shapeType
	}
	
	///Returns (xMin, xMax)
	func getBoundingX: (Double, Double) {
		//Assume returned as little endian
		return (xMin, xMax)
	}
	
}
