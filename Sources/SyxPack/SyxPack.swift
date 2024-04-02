import ByteKit

/// Protocol for MIDI System Exclusive data.
public protocol SystemExclusiveData {
    /// Gets the data as a byte array.
    func asData() -> ByteArray
    
    /// Gets the length of the data.
    var dataLength: Int { get }
}

/// Identifies a MIDI System Exclusive message based on its data content.
public func identifyMessage(data: ByteArray) {
    guard 
        data.count >= Message.minimumByteCount
    else {
        print("Not enough bytes to be a System Exclusive message")
        return
    }
    
    guard 
        data.first == Message.initiator
    else {
        print("First byte is \(String(format: "%02X", data.first!))H, not System Exclusive initiator")
        return
    }
    
    guard 
        data.last == Message.terminator
    else {
        print("Last byte is \(String(format: "%02X", data.last!))H, not System Exclusive terminator")
        return
    }
    
    let terminatorOffset = data.count - 1
    var payloadStartOffset = 2
    let shortDump = HexDumpConfiguration(
        bytesPerLine: 8,
        uppercased: true,
        includeOptions: []
    )

    switch data[1] {
    case Universal.Kind.nonRealTimeIdentifier:
        print("Universal Non-Realtime System Exclusive message")
    case Universal.Kind.realTimeIdentifier:
        print("Universal Realtime System Exclusive message")
    case Manufacturer.developmentIdentifierByte:
        print("Development")
    case Manufacturer.extendedIdentifierFirstByte:
        print("Manufacturer-specific System Exclusive message (extended)")
        let manufacturer = Manufacturer.extended((data[1], data[2], data[3]))
        print("Manufacturer:\n\(manufacturer)")
        payloadStartOffset += 2
    default:
        print("Manufacturer-specific System Exclusive message (standard)")
        let manufacturer = Manufacturer.standard(data[1])
        print("Manufacturer:\n\(manufacturer)")
    }

    let payloadLength = terminatorOffset - payloadStartOffset
    print("Payload: \(payloadLength) bytes")
    let bytesToPrint = min(16, payloadLength)
    print(ByteArray(data[payloadStartOffset ..< payloadStartOffset + bytesToPrint]).hexDump(configuration: shortDump))
    if bytesToPrint < payloadLength {
        print(" (+ \(payloadLength - bytesToPrint) more bytes)")
    }
}
