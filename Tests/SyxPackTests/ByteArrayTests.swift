import XCTest
@testable import SyxPack

final class ByteArrayTests: XCTestCase {
    func test_nybblified() {
        let ba = ByteArray([0xa4, 0xb5, 0xc6])
        XCTAssertEqual(ba.nybblified(), ByteArray([0x0a, 0x04, 0x0b, 0x05, 0x0c, 0x06]))
    }
    
    func test_denybblified_notEven() {
        let ba = ByteArray([0x0a, 0x04, 0x0b, 0x05, 0x0c])  // byte count is odd
        XCTAssertNil(ba.denybblified())  // should return nil
    }
    
    func test_denybblified() {
        let ba = ByteArray([0x0a, 0x04, 0x0b, 0x05, 0x0c, 0x06])
        XCTAssertEqual(ba.denybblified(), ByteArray([0xa4, 0xb5, 0xc6]))
    }
}
