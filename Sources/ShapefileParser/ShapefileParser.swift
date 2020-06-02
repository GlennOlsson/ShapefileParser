import Foundation

class ShapefileParser {
	
	private static func parseHeader(data: NSData) throws -> ShapefileHeader{
		let intRange = NSRange(location: 0, length: 9 * 4) //9 Int32 with 4 bytes of size
		var intBuffer = [Int32](repeating: 0, count: 9) //Buffer of 9 ints
		data.getBytes(&intBuffer, range: intRange)
		
		let fileCode = intBuffer[0].bigEndian
		guard fileCode == 9994 else { throw ShapeParserError.badFileCode }
		
		let fileLength = intBuffer[6].bigEndian
		let shapeTypeValue = intBuffer[8].littleEndian
		guard let shapeType = ShapeType.create(shapeTypeValue) else { throw ShapeParserError.badShapeType }
		
		let doubleRange = NSRange(location: 36, length: 8 * 8) //8 Doubles with 8 bytes of size
		var doubleBuffer = [Double](repeating: 0, count: 8)
		data.getBytes(&doubleBuffer, range: doubleRange)
		
		let xMin = doubleBuffer[0]
		let xMax = doubleBuffer[1]
		let yMin = doubleBuffer[2]
		let yMax = doubleBuffer[3]
		let zMin = doubleBuffer[4]
		let zMax = doubleBuffer[5]
		let mMin = doubleBuffer[6]
		let mMax = doubleBuffer[7]
		
		print("xMin: \(xMin)")
		print("xMax: \(xMax)")
		print("yMin: \(yMin)")
		print("yMax: \(yMax)")
		print("zMin: \(zMin)")
		print("zMax: \(zMax)")
		print("mMin: \(mMin)")
		print("mMax: \(mMax)")
		
		let header = ShapefileHeader(fileLength: fileLength, shapeType: shapeType, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax, mMin: mMin, mMax: mMax)
		return header
	}
	
	private static func parseRecord(filedata: NSData, startByte: Int, length: Int32) {
		var byteIndex = startByte.littleEndian
		
		var type: Int32 = 0
		filedata.getBytes(&type, range: NSRange(location: byteIndex, length: 4))
//		print("Type is MultiPath (31) ? \(String(type.littleEndian))")
		byteIndex += 4
		
		var boxBuffer = [Double](repeating: 0, count: 4)
		filedata.getBytes(&boxBuffer, range: NSRange(location: byteIndex, length: 4 * 8)) //4 doubles
		byteIndex += 4 * 8
		
//		print(boxBuffer)
		
		var numParts: Int32 = 0
		var numPoints: Int32 = 0
		
		filedata.getBytes(&numParts, range: NSRange(location: byteIndex, length: 4))
		filedata.getBytes(&numPoints, range: NSRange(location: byteIndex + 4, length: 4))
		byteIndex += 8
		
		
		byteIndex += (16 * Int(numPoints)) + (2 * (4 * Int(numParts)))
		var zMin: Double = 0
		var zMax: Double = 0
		filedata.getBytes(&zMin, range: NSRange(location: byteIndex, length: 8))
		filedata.getBytes(&zMax, range: NSRange(location: byteIndex + 8, length: 8))
		byteIndex += 16
		
		
		for _ in 0..<Int(numPoints) {
			var db: Double = 0
			filedata.getBytes(&db, range: NSRange(location: byteIndex, length: 8))
			print("Double: \(db)")
			byteIndex += 8
		}
		
		print("zMin, zMax: \((zMin, zMax)), numPoints: \(Int(numPoints)), numParts: \(Int(numParts))")
		
		var mMin: Double = 0
		var mMax: Double = 0
		filedata.getBytes(&mMin, range: NSRange(location: byteIndex, length: 8))
		filedata.getBytes(&mMax, range: NSRange(location: byteIndex + 8, length: 8))
		print("mMin, mMax: \((mMin, mMax)), numPoints: \(Int(numPoints)), numParts: \(Int(numParts))")
		byteIndex += 16
	}
	
	private static func parseRecords<Record: ShapeRecord>(shapefile: inout Shapefile<Record>, filedata: NSData) {
		var byteIndex = 100 //First header after init header
		//The amount of 16bit words (2 bytes). -100 because of header size
		let upperBound = (shapefile.getFileLength() - 100) * 2
		var counter = 0
		while byteIndex < upperBound {
			counter += 1
			let recordHeaderRange = NSRange(location: byteIndex, length: 8) //Record header is 8 bytes
			var recordHeaderBuffer = [Int32](repeating: 0, count: 2)
			filedata.getBytes(&recordHeaderBuffer, range: recordHeaderRange)
			
			let recordNumber = recordHeaderBuffer[0].bigEndian
			let recordLength = recordHeaderBuffer[1].bigEndian
			
			parseRecord(filedata: filedata, startByte: byteIndex + 8, length: recordLength) //+4 as first byte is type
			
			byteIndex += 8 + (2 * Int(recordLength)) //8 is size of header, 2 * 16 because 16 bit words = 2 bytes
		}
		print("Count of records: \(counter)")
	}
	
	static func parse(filepath: String) throws {
		guard let data = NSData(contentsOfFile: filepath) else { throw ShapeParserError.noSuchFile }
		
		let header = try parseHeader(data: data)
		if header.getShapeType() == .multiPatch {
			var shapefile = Shapefile<MultiPatch>(header: header)
			parseRecords(shapefile: &shapefile, filedata: data)
		} else {
			print("Shapetype not supported: \(header.getShapeType())")
		}
//		return shapefile
	}
}
