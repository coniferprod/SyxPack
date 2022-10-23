import XCTest
@testable import SyxPack

final class ManufacturerTests: XCTestCase {
    func test_standardIdentifier() {
        let manufacturer = Manufacturer.standard(0x43)
        XCTAssertEqual(manufacturer.name, "Yamaha")
    }
    
    func test_extendedIdentifier() {
        let manufacturer = Manufacturer.extended((0x00, 0x00, 0x0E))
        XCTAssertEqual(manufacturer.name, "Alesis Studio Electronics")
    }
    
    func test_isEqual() {
        let m1 = Manufacturer.standard(0x42)
        let m2 = Manufacturer.standard(0x42)
        XCTAssertTrue(m1 == m2)
    }
}
