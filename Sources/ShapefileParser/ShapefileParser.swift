import Foundation

class ShapefileParser {
	
	private static func parseHeader(data: NSData) throws -> Shapefile {
		let intRange = NSRange(location: 0, length: 9 * 4) //9 Int32 with 4 bytes of size
		var intBuffer = [Int32](repeating: 0, count: 9) //Buffer of 9 ints
		data.getBytes(&intBuffer, range: intRange)
		
		let fileCode = intBuffer[0]
		guard fileCode == 9994 else { throw ShapeParserError.badFileCode }
		
		let fileLength = intBuffer[7].bigEndian
		let shapeTypeValue = intBuffer[9].littleEndian
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
		
		let shapefile = Shapefile(fileLength: fileLength, shapeType: shapeType, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax, mMin: mMin, mMax: mMax)
		return shapefile
	}
	
	private static func parseRecords(shapefile: inout Shapefile, filedata: NSData) {
		var byteIndex = 100 //First header after init header
		while byteIndex < shapefile.getFileLength() {
			let recordHeaderRange = NSRange(location: byteIndex, length: 8) //Record header is 8 bytes
			var recordHeaderBuffer = [Int32](repeating: 0, count: 2)
			filedata.getBytes(&recordHeaderBuffer, range: recordHeaderBuffer)
			
			let recordNumber = recordHeaderBuffer[0]
			let recordLength = recordHeaderBuffer[1]
			
			print("Current record; nr: \(recordNumber) of size \(recordLength) words")
			byteIndex += 8 + (2 * 16) //8 is size of header, 2 * 16 because 16 bit words = 2 bytes
		}
	}
	
	static func parse(filepath: String) throws -> Shapefile {
		guard let data = NSData(contentsOfFile: filepath) else { throw ShapeParserError.noSuchFile }
		
		let totalFileLength = data.count
		
		var shapefile = try parseHeader(data: data)
		
		parseRecords(file: &shapefile)
		
		print("Total length: \(totalFileLength), derrived from file: \(shapefile.getFileLength())")
		
		return shapefile
	}
}
