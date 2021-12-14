import XCTest
@testable import SyxPack

final class SyxPackTests: XCTestCase {
    func test_chunked_arrayLengthIsLessThanChunkSize() {
        let data: ByteArray = [0x41, 0x42, 0x43]
        let chunks = data.chunked(into: 16)
        XCTAssertEqual(chunks.count, 1)
    }

    func test_chunked_arrayLengthIsExactlyChunkSize() {
        let data = ByteArray(repeating: 0x42, count: 16)
        let chunks = data.chunked(into: 16)
        XCTAssertEqual(chunks.count, 1)
    }

    func test_chunked_arrayLengthIsGreaterThanChunkSize() {
        let data = ByteArray(repeating: 0x42, count: 24)
        let chunks = data.chunked(into: 16)
        XCTAssertEqual(chunks.count, 2)
        XCTAssertEqual(chunks.last!.count, 8)
    }

    func test_sourceCodeIsGeneratedCorrectly() {
        let data: ByteArray = [0x41, 0x42, 0x43]
        let config = SourceDumpConfig(
            bytesPerLine: 8,
            uppercased: true,
            variableName: "data",
            typeName: "ByteArray",
            indent: 4)
        let dump = data.sourceDump(config: config)
        XCTAssertEqual(dump, "let data: ByteArray = [\n    0x41, 0x42, 0x43, \n]")
    }
    
    /*
    func test_message_universal_nonRealTime_isConstructedFromBytesCorrectly() {
        // KORG minilogue xd Identity Reply (Universal Non-Realtime
        let data: ByteArray = [0xF0, 0x7E, 0x00, 0x06, 0x02, 0x42, 0x51, 0x01, 0x00, 0x00,
                               0x01, 0x01, 0x01, 0x01, 0xF7]
        if let message = Message(data: data) {
            XCTAssertEqual(message, Message.universal(.nonRealTime, Universal.Header(deviceChannel: 0x00, subId1: 0x06, subId2: 0x02)))
            XCTAssertEqual(message.payload.count, 12)
        }
        else {
            XCTFail("Unable to construct message")
        }
    }
    
    func test_message_universal_realTime_isConstructedFromBytesCorrectly() {
        
    }

    func test_message_manufacturer_isConstructedFromBytesCorrectly() {
        
    }
     */
}
