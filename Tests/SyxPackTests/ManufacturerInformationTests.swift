import Foundation

import XCTest
@testable import SyxPack

final class ManufacturerInformationTests: XCTestCase {
    func test_Group_isCorrect() {
        let manufacturer = Manufacturer.yamaha
        XCTAssertEqual(manufacturer.group, .japanese)
    }

    func test_canonicalNameIsCorrect() {
        let manufacturer = Manufacturer.yamaha
        XCTAssertEqual(manufacturer.canonicalName, "Yamaha Corporation")
    }

    func test_displayNameIsCorrect() {
        let manufacturer = Manufacturer.yamaha
        XCTAssertEqual(manufacturer.displayName, "Yamaha Corporation")
    }
}
