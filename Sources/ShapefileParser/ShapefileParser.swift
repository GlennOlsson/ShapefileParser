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
	
	private static func parseRecords<Record: ShapeRecord>(shapefile: inout Shapefile<Record>, filedata: NSData) throws {
		var byteIndex = 100 //First header after init header
		//The amount of 16bit words (2 bytes). -100 because of header size
		let upperBound = (shapefile.getFileLength() - 100) * 2
		var counter = 0
		while byteIndex < upperBound {
			counter += 1
		
			let record = try shapefile.parseRecord(data: filedata, offset: byteIndex) //+4 as first byte is type
			
			byteIndex += 8 + (2 * Int(record.recordLength)) //8 is size of header, 2 * 16 because 16 bit words = 2 bytes
		}
		print("Count of records: \(counter)")
	}
	
	static func parse(filepath: String) throws {
		guard let data = NSData(contentsOfFile: filepath) else { throw ShapeParserError.noSuchFile }
		
		let header = try parseHeader(data: data)
		if header.getShapeType() == .multiPatch {
			var shapefile = Shapefile<MultiPatch>(header: header)
			try parseRecords(shapefile: &shapefile, filedata: data)
		} else {
			print("Shapetype not supported: \(header.getShapeType())")
		}
//		return shapefile
	}
}
