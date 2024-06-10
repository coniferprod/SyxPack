import XCTest
@testable import SyxPack
import ByteKit

final class MessageTests: XCTestCase {
    let standardManufacturerMessageBytes: ByteArray = [
        0xf0,  // SysEx start
        0x40,  // Kawai
        0x00,  // channel 1
        0x00,  // one patch data request
        0x00,  // synthesizer group
        0x04,  // Kawai K4/K4r ID
        0x00,  // internal
        0x00,  // patch A-1
        0xf7,  // SysEx end
    ]
    
    let extendedManufacturerMessageBytes: ByteArray = [
        0xf0,
        0x00, 0x00, 0x0e,  // Alesis
        0x00, 0x41, 0x61, 0x00, 0x5d, // Alesis V25 config command
        0x00,  // not actually a valid message, just testing
        0xf7,
    ]
    
    func test_message_initFromBytes_standard() {
        if case let .failure(error) = Message.parse(from: standardManufacturerMessageBytes) {
            XCTFail("Unable to parse message, error = \(error)")
        }
    }

    func test_message_initFromBytes_extended() {
        if case let .failure(error) = Message.parse(from: extendedManufacturerMessageBytes) {
            XCTFail("Unable to parse message, error = \(error)")
        }
    }
    
    func test_message_payload_standard() {
        switch Message.parse(from: standardManufacturerMessageBytes) {
        case .success(let message):
            let payload = message.payload
            XCTAssertEqual(payload.count, 6)
        case .failure(let error):
            XCTFail("Unable to parse message, error = \(error)")
        }
    }
    
    func test_message_payload_extended() {
        switch Message.parse(from: extendedManufacturerMessageBytes) {
        case .success(let message):
            let payload = message.payload
            XCTAssertEqual(payload.count, 6)
        case .failure(let error):
            XCTFail("Unable to parse message, error = \(error)")
        }
    }
}
