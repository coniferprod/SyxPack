import XCTest
@testable import SyxPack

final class ByteArrayTests: XCTestCase {
    func test_nybblified_highFirst() {
        let ba = ByteArray([0xa4, 0xb5, 0xc6])
        XCTAssertEqual(ba.nybblified(), ByteArray([0x0a, 0x04, 0x0b, 0x05, 0x0c, 0x06]))
    }
    
    func test_nybblified_lowFirst() {
        let ba = ByteArray([0xa4, 0xb5, 0xc6])
        XCTAssertEqual(ba.nybblified(highFirst: false), ByteArray([0x04, 0x0a, 0x05, 0x0b, 0x06, 0x0c]))
    }

    func test_denybblified_notEven() {
        let ba = ByteArray([0x0a, 0x04, 0x0b, 0x05, 0x0c])  // byte count is odd
        XCTAssertNil(ba.denybblified())  // should return nil
    }
    
    func test_denybblified_highFirst() {
        let ba = ByteArray([0x0a, 0x04, 0x0b, 0x05, 0x0c, 0x06])
        XCTAssertEqual(ba.denybblified(), ByteArray([0xa4, 0xb5, 0xc6]))
    }

    func test_denybblified_lowFirst() {
        let ba = ByteArray([0x0a, 0x04, 0x0b, 0x05, 0x0c, 0x06])
        XCTAssertEqual(ba.denybblified(highFirst: false), ByteArray([0x4a, 0x5b, 0x6c]))
    }

    func test_denybblified_empty() {
        let ba = ByteArray()
        XCTAssertEqual(ba.denybblified()!.count, ba.count)
    }
}
