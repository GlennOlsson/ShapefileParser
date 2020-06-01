import XCTest

@testable import ShapefileParser

final class ShapefileParserTests: XCTestCase {
    func testSodermalm() {
		guard let path = Bundle(for: type(of: self)).path(forResource: "Byggnad", ofType: "shp") else {
			print("No file, bro")
			return
		}
		do {
			_ = try ShapefileParser.parse(filepath: path)
		} catch {
			print("Error! \(error)")
			assertionFailure()
		}
    }

    static var allTests = [
        ("testSodermalm", testSodermalm),
    ]
}
