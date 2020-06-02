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
	
	var xMin: Double
	var xMax: Double
	var yMin: Double
	var yMax: Double
	
	var zMin: Double
	var zMax: Double
	var mMin: Double
	var mMax: Double
	
	var points: [Point]
	
	var zArray: [Double]
	var mArray: [Double]
	
	init(recordNumber: Int32, recordLength: Int32, xMin: Double, xMax: Double, yMin: Double, yMax: Double, zMin: Double, zMax: Double, mMin: Double, mMax: Double, points: [Point], zArray: [Double], mArray: [Double]) {
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
}
