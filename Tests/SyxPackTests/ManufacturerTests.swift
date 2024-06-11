import XCTest
@testable import SyxPack
import ByteKit

final class ManufacturerTests: XCTestCase {
    func test_standardIdentifier() {
        let manufacturer = Manufacturer.standard(0x43)
        XCTAssertEqual(manufacturer.name, "Yamaha")
    }
    
    func test_extendedIdentifier() {
        let manufacturer = Manufacturer.extended(0x00, 0x0E)
        XCTAssertEqual(manufacturer.name, "Alesis Studio Electronics")
    }
    
    func test_isEqual() {
        let m1 = Manufacturer.standard(0x42)
        let m2 = Manufacturer.standard(0x42)
        XCTAssertTrue(m1 == m2)
    }
    
    func test_invalidManufacturer() {
        let result = Manufacturer.parse(from: [0x60])
        XCTAssertEqual(result, .failure(.invalidManufacturer([0x60])))
    }
    
    func test_unknownManufacturer() {
        let result = Manufacturer.parse(from: [0x45])
        switch result {
        case .success(let manufacturer):
            XCTAssertEqual("\(manufacturer)", "(unknown) (45)")
        case .failure(let error):
            XCTFail("\(error)")
        }
    }
    
    func test_manufacturerCount() {
        let count = Manufacturer.count
        print("Number of manufacturers known: \(count)")
        XCTAssert(count > 0)
    }
}
