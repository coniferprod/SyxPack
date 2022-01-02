import XCTest
@testable import SyxPack

final class ByteTests: XCTestCase {
    func test_highNybble() {
        let b: Byte = 0xa4
        XCTAssertEqual(b.highNybble, 0x0a)
    }

    func test_lowNybble() {
        let b: Byte = 0xa4
        XCTAssertEqual(b.lowNybble, 0x04)
    }

    func test_nybblesFromByte() {
        let b: Byte = 0xa4
        let nybbles = b.nybbles
        XCTAssertEqual(nybbles.high, 0x0a)
        XCTAssertEqual(nybbles.low, 0x04)
    }
    
    func test_initFromNybbles() {
        let nybbles: Nybbles = (high: 0x0a, low: 0x04)
        let b = Byte(nybbles: nybbles)
        XCTAssertEqual(b, 0xa4)
    }
}
