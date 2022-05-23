import XCTest
@testable import SyxPack

final class ManufacturerTests: XCTestCase {
    func test_standardIdentifier() {
        let manufacturer = Manufacturer(identifier: .standard(0x43))
        XCTAssertEqual(manufacturer.canonicalName, "Yamaha Corporation")
    }
    
    func test_extendedIdentifier() {
        let manufacturer = Manufacturer(identifier: .extended((0x00, 0x00, 0x0E)))
        XCTAssertEqual(manufacturer.canonicalName, "Alesis Studio Electronics")
    }
    
    func test_identifierIsEqual() {
        let id1: Manufacturer.Identifier = .standard(0x42)
        let id2: Manufacturer.Identifier = .standard(0x42)
        XCTAssertTrue(id1 == id2)
    }
    
    func test_isEqual() {
        let manuf1 = Manufacturer.korg
        let manuf2 = Manufacturer.korg
        XCTAssertTrue(manuf1 == manuf2)
    }
}
