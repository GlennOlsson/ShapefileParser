import Foundation

class ShapefileParser {
	
	private static func parseHeader(data: NSData) throws -> Shapefile {
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
		
		let shapefile = Shapefile(fileLength: fileLength, shapeType: shapeType, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax, mMin: mMin, mMax: mMax)
		return shapefile
	}
	
	private static func parseRecords(shapefile: inout Shapefile, filedata: NSData) {
		var byteIndex = 100 //First header after init header
		//The amount of 16bit words (2 bytes). -100 because of header size
		let upperBound = (shapefile.getFileLength() - 100) * 2
		while byteIndex < upperBound {
			let recordHeaderRange = NSRange(location: byteIndex, length: 8) //Record header is 8 bytes
			var recordHeaderBuffer = [Int32](repeating: 0, count: 2)
			
			let recordNumber = recordHeaderBuffer[0].bigEndian
			let recordLength = recordHeaderBuffer[1].bigEndian
			
			byteIndex += 8 + (2 * Int(recordLength)) //8 is size of header, 2 * 16 because 16 bit words = 2 bytes
		}
	}
	
	static func parse(filepath: String) throws -> Shapefile {
		print("Begin")
		guard let data = NSData(contentsOfFile: filepath) else { throw ShapeParserError.noSuchFile }
		print("Got data")
		let totalFileLength = data.count
		
		var shapefile = try parseHeader(data: data)
		print("Parsed header")
		parseRecords(shapefile: &shapefile, filedata: data)
		print("Parsed Records")
		print("Total length: \(totalFileLength), derrived from file: \(shapefile.getFileLength())")
		
		return shapefile
	}
}
