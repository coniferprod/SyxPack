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
    let shortDump = HexDumpConfiguration(
        bytesPerLine: 8,
        uppercased: true,
        includeOptions: []
    )

    switch Message.parse(from: data) {
    case .success(let message):
        print("\(message)")
        let bytesToPrint = min(16, message.payload.count)
        print(ByteArray(message.payload[..<bytesToPrint]).hexDump(configuration: shortDump))
        if bytesToPrint < message.payload.count {
            print(" (+ \(message.payload.count - bytesToPrint) more bytes)")
        }
    case .failure(let error):
        print("Error parsing message: \(error)")
    }    
}
