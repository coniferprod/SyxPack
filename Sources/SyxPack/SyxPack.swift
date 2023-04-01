import Foundation

extension Data {
    /// Returns the contents of this `Data` object as a byte array.
    public var bytes: ByteArray {
        var byteArray = ByteArray(repeating: 0, count: self.count)
        self.copyBytes(to: &byteArray, count: self.count)
        return byteArray
    }
}

/// Configuration object for the hex dump of a byte array.
public struct HexDumpConfig {
    /// Flags to control the inclusion of hex dump features.
    public struct IncludeOptions: OptionSet {
        public let rawValue: UInt8

        public static let offset = IncludeOptions(rawValue: 1)
        public static let printableCharacters = IncludeOptions(rawValue: 1 << 1)
        public static let midChunkGap = IncludeOptions(rawValue: 1 << 2)
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
    
    public var bytesPerLine: Int
    public var uppercased: Bool
    public var includeOptions: IncludeOptions
    public var indent: Int

    /// Default hex dump configuration
    public static let defaultConfig = HexDumpConfig(
        bytesPerLine: 16,
        uppercased: true,
        includeOptions: [.offset, .printableCharacters, .midChunkGap],
        indent: 0)
    
    /// Simple hex dump configuration
    public static let plainConfig = HexDumpConfig(
        bytesPerLine: 16,
        uppercased: true,
        includeOptions: [],
        indent: 0)
}

/// Configuration object for the source code dump of this byte array.
public struct SourceDumpConfig {
    public var bytesPerLine: Int
    public var uppercased: Bool
    public var variableName: String
    public var typeName: String
    public var indent: Int
    
    /// Default source dump configuration
    public static let defaultConfig = SourceDumpConfig(
        bytesPerLine: 16,
        uppercased: true,
        variableName: "data",
        typeName: "[UInt8]",
        indent: 4
    )
}

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Character {
    /// Returns `true` if this character is a printable ASCII character,
    /// `false` otherwise.
    public var isPrintable: Bool {
        if let v = self.asciiValue {
            if v >= 0x20 && v < 0x7f {
                return true
            }
        }
        return false
    }
}

/// Identifies a MIDI System Exclusive message based on its data content.
public func identifyMessage(data: ByteArray) {
    guard data.count >= Message.minimumByteCount else {
        print("Not enough bytes to be a System Exclusive message")
        return
    }
    
    guard data.first == Message.initiator else {
        print("First byte is not System Exclusive initiator \(String(format: "%02X", Message.initiator))H")
        return
    }
    
    guard data.last == Message.terminator else {
        print("Last byte is not System Exclusive terminator \(String(format: "%02X", Message.terminator))H")
        return
    }
    
    let terminatorOffset = data.count - 1
    var payloadStartOffset = 2
    let simpleHexDumpConfig = HexDumpConfig(
        bytesPerLine: 8, uppercased: true,
        includeOptions: [], indent: 0)

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
    print(ByteArray(data[payloadStartOffset ..< payloadStartOffset + bytesToPrint]).hexDump(config: simpleHexDumpConfig))
    if bytesToPrint < payloadLength {
        print(" (+ \(payloadLength - bytesToPrint) more bytes)")
    }
}
