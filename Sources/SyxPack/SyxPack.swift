import Foundation

extension Data {
    public var bytes: ByteArray {
        var byteArray = ByteArray(repeating: 0, count: self.count)
        self.copyBytes(to: &byteArray, count: self.count)
        return byteArray
    }
}

public struct HexDumpConfig {
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
    
    public static let defaultConfig = HexDumpConfig(
        bytesPerLine: 16,
        uppercased: true,
        includeOptions: [.offset, .printableCharacters, .midChunkGap],
        indent: 0)
    
    public static let plainConfig = HexDumpConfig(
        bytesPerLine: 16,
        uppercased: true,
        includeOptions: [],
        indent: 0)
}

public struct SourceDumpConfig {
    public var bytesPerLine: Int
    public var uppercased: Bool
    public var variableName: String
    public var typeName: String
    public var indent: Int
    
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
    var isPrintable: Bool {
        if let v = self.asciiValue {
            if v >= 0x20 && v < 0x7f {
                return true
            }
        }
        return false
    }
}

public func identifyMessage(data: ByteArray) {
    guard data.count >= 5 else {
        print("Too few bytes for a System Exclusive message")
        return
    }
    
    guard data.first == 0xF0 else {
        print("Not initiated by F0H")
        return
    }
    
    guard data.last == 0xF7 else {
        print("Not terminated by F7H")
        return
    }
    
    let terminatorOffset = data.count - 1
    var payloadStartOffset = 2
    let simpleHexDumpConfig = HexDumpConfig(
        bytesPerLine: 8, uppercased: true,
        includeOptions: [], indent: 0)

    switch data[1] {
    case 0x7E:
        print("Universal Non-Realtime System Exclusive message")
    case 0x7F:
        print("Universal Realtime System Exclusive message")
    case 0x7D:
        print("Development")
    case 0x00:
        print("Manufacturer-specific System Exclusive message")
        let manufacturer = Manufacturer(identifier: .extended((data[1], data[2], data[3])))
        print("Manufacturer:\n\(manufacturer)")
        payloadStartOffset += 2
    default:
        print("Manufacturer-specific System Exclusive message")
        let manufacturer = Manufacturer(identifier: .standard(data[1]))
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
