//
//  MultiPatch.swift
//  
//
//  Created by Glenn Olsson on 2020-06-02.
//

import Foundation

class MultiPatch: ShapeRecord {	
	
	var recordNumber: Int32
	
	var recordLength: Int32
	
	static var shapeType: Int32 = ShapeType.multiPatch.rawValue
	
	var xMin: Double
	var xMax: Double
	var yMin: Double
	var yMax: Double
	
	var zMin: Double
	var zMax: Double
	var mMin: Double?
	var mMax: Double?
	
	var points: [Point]
	
	var zArray: [Double]
	var mArray: [Double]?
	
	init(recordNumber: Int32, recordLength: Int32, xMin: Double, xMax: Double, yMin: Double, yMax: Double, zMin: Double, zMax: Double, mMin: Double?, mMax: Double?, points: [Point], zArray: [Double], mArray: [Double]?) {
		self.recordNumber = recordNumber
		self.recordLength = recordLength
		
		self.xMin = xMin
		self.xMax = xMax
		self.yMin = yMin
		self.yMax = yMax
		
		self.zMin = zMin
		self.zMax = zMax
		self.mMin = mMin
		self.mMax = mMax
		
		self.points = points
		
		self.zArray = zArray
		self.mArray = mArray
		
		
	}
	
	static func parse<Record>(data: NSData, offset: Int, mIsActive: Bool) throws -> Record where Record : ShapeRecord {
		var byteIndex = offset.littleEndian
		
		let recordHeaderRange = NSRange(location: byteIndex, length: 8) //Record header is 8 bytes
		var recordHeaderBuffer = [Int32](repeating: 0, count: 2)
		data.getBytes(&recordHeaderBuffer, range: recordHeaderRange)
		
		let recordNumber = recordHeaderBuffer[0].bigEndian
		let recordLength = recordHeaderBuffer[1].bigEndian
		byteIndex += 8
		
		var type: Int32 = 0
		data.getBytes(&type, range: NSRange(location: byteIndex, length: 4))
		
		if type != MultiPatch.shapeType {
			throw ShapeParserError.badShapeType
		}
		
		byteIndex += 4
		
		var boxBuffer = [Double](repeating: 0, count: 4)
		data.getBytes(&boxBuffer, range: NSRange(location: byteIndex, length: 4 * 8)) //4 doubles
		byteIndex += 4 * 8
		
		var numParts: Int32 = 0
		var numPoints: Int32 = 0
		
		data.getBytes(&numParts, range: NSRange(location: byteIndex, length: 4))
		data.getBytes(&numPoints, range: NSRange(location: byteIndex + 4, length: 4))
		byteIndex += 8
		
		var partsBuffer = [Int32](repeating: 0, count: Int(numParts.littleEndian))
		data.getBytes(&partsBuffer, range: NSRange(location: byteIndex, length: Int(numParts.littleEndian)  * 4)) //numparts Int32 á 4 bytes
		byteIndex += 4 * Int(numParts.littleEndian)
		
		//Points are only x, y - no headers
		//This as according to doc., the points are 16 bytes = 2*8 bytes doubles
		var pointsDoubleBuffer = [Double](repeating: 0, count: 2 * Int(numPoints.littleEndian)) //2 doubles per point
		data.getBytes(&pointsDoubleBuffer, range: NSRange(location: byteIndex, length: Int(numPoints.littleEndian) * 16))
		byteIndex += Int(numPoints.littleEndian) * 16
		
		var pointsArray: [Point] = []
		for i in stride(from: 0, to: pointsDoubleBuffer.count, by: 2) {
			let x = pointsDoubleBuffer[i]
			let y = pointsDoubleBuffer[i + 1]
			pointsArray.append(Point(x: x, y: y))
		}
		
		var zMin: Double = 0
		var zMax: Double = 0
		data.getBytes(&zMin, range: NSRange(location: byteIndex, length: 8))
		data.getBytes(&zMax, range: NSRange(location: byteIndex + 8, length: 8))
		byteIndex += 16
		
		var zArrayBuffer = [Double](repeating: 0, count: Int(numPoints.littleEndian))
		data.getBytes(&zArrayBuffer, range: NSRange(location: byteIndex, length: Int(numPoints.littleEndian) * 8))
		byteIndex += 8 * Int(numPoints.littleEndian)

		var mMin: Double?
		var mMax: Double?
		var mArrayBuffer: [Double]?
		if mIsActive {
			mMin = 0
			mMax = 0
			data.getBytes(&mMin, range: NSRange(location: byteIndex, length: 8))
			data.getBytes(&mMax, range: NSRange(location: byteIndex + 8, length: 8))
			byteIndex += 16
			
			mArrayBuffer = [Double](repeating: 0, count: Int(numPoints.littleEndian))
			data.getBytes(&mArrayBuffer, range: NSRange(location: byteIndex, length: Int(numPoints.littleEndian) * 8))
		}
		
		
		let record = MultiPatch(recordNumber: recordNumber, recordLength: recordLength, xMin: boxBuffer[0], xMax: boxBuffer[2], yMin: boxBuffer[1], yMax: boxBuffer[3], zMin: zMin, zMax: zMax, mMin: mMin, mMax: mMax, points: pointsArray, zArray: zArrayBuffer, mArray: mArrayBuffer)
		return record as! Record
	}

}
