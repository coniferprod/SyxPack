import XCTest
@testable import SyxPack

final class ManufacturerTests: XCTestCase {
    func test_displayNameIsCorrect() {
        let manufacturer = Manufacturer.yamaha
        XCTAssertEqual(manufacturer.displayName, "Yamaha")
    }
    
    func test_identifierIsEqual() {
        let id1: Manufacturer.Identifier = .standard(0x42)
        let id2: Manufacturer.Identifier = .standard(0x42)
        XCTAssertTrue(id1 == id2)
    }
}
