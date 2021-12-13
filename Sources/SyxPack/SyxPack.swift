import Foundation

public typealias Byte = UInt8
public typealias ByteArray = [Byte]
public typealias ByteTriplet = (Byte, Byte, Byte)


extension Data {
    var bytes: ByteArray {
        var byteArray = ByteArray(repeating: 0, count: self.count)
        self.copyBytes(to: &byteArray, count: self.count)
        return byteArray
    }
}

struct HexDumpConfig {
    struct IncludeOptions: OptionSet {
        let rawValue: UInt8

        static let offset = IncludeOptions(rawValue: 1)
        static let printableCharacters = IncludeOptions(rawValue: 1 << 1)
        static let midChunkGap = IncludeOptions(rawValue: 1 << 2)
    }
    
    var bytesPerLine: Int
    var uppercased: Bool
    var includeOptions: IncludeOptions
    var indent: Int
    
    static let defaultConfig = HexDumpConfig(
        bytesPerLine: 16,
        uppercased: true,
        includeOptions: [.offset, .printableCharacters, .midChunkGap],
        indent: 0
    )
}

struct SourceDumpConfig {
    var bytesPerLine: Int
    var uppercased: Bool
    var variableName: String
    var typeName: String
    var indent: Int
    
    static let defaultConfig = SourceDumpConfig(
        bytesPerLine: 16,
        uppercased: true,
        variableName: "data",
        typeName: "[UInt8]",
        indent: 4
    )
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
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

extension ByteArray {
    func hexDump(config: HexDumpConfig = .defaultConfig) -> String {
        var lines = [String]()

        let chunks = self.chunked(into: config.bytesPerLine)
        var offset = 0
        let hexModifier = config.uppercased ? "X" : "x"
        let midChunkIndex = config.bytesPerLine / 2
        for chunk in chunks {
            var line = String(repeating: " ", count: config.indent)
            var printableCharacters = ""

            if config.includeOptions.contains(.offset) {
                line += String(format: "%08\(hexModifier)", offset)
                line += ": "
            }
        
            for (index, byte) in chunk.enumerated() {
                line += String(format: "%02\(hexModifier)", byte)
                line += " "
                
                if index + 1 == midChunkIndex {
                    if config.includeOptions.contains(.midChunkGap) {
                        line += " "
                    }
                }
                
                let ch = Character(Unicode.Scalar(byte))
                printableCharacters += ch.isPrintable ? String(ch) : "."
            }

            // Insert spaces for each unused byte slot in the chunk
            var bytesLeft = config.bytesPerLine - chunk.count
            while bytesLeft >= 0 {
                line += "   "  // this is for the byte, to replace "XX "
                printableCharacters += " "  // handle characters too, even if we don't use them
                bytesLeft -= 1
            }

            if config.includeOptions.contains(.printableCharacters) {
                line += " "
                line += printableCharacters
            }
            
            lines.append(line)
            offset += config.bytesPerLine
        }
        
        return lines.joined(separator: "\n")
    }

    func sourceDump(config: SourceDumpConfig = .defaultConfig) -> String {
        var lines = [String]()
        
        lines.append("let \(config.variableName): \(config.typeName) = [")

        let chunks = self.chunked(into: config.bytesPerLine)
        let hexModifier = config.uppercased ? "X" : "x"
        for chunk in chunks {
            var line = String(repeating: " ", count: config.indent)
            for byte in chunk {
                line.append("0x\(String(format: "%02\(hexModifier)", byte)), ")
            }
            lines.append(line)
        }

        lines.append("]")
        return lines.joined(separator: "\n")
    }
}

public func identifyMessage(data: [UInt8]) {
    guard data.count >= 4 else {
        print("Too few bytes for a System Exclusive message")
        return
    }
    
    guard data[0] == 0xF0 else {
        print("Not initiated by F0H")
        return
    }
    
    guard data.last == 0xF7 else {
        print("Not terminated by F7H")
        return
    }
    
    let terminatorOffset = data.count - 1
    var payloadOffset = 2
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
        let manufacturerId: ByteArray = [
            data[1], data[2], data[3]
        ]
        print("Manufacturer ID: Extended, \(manufacturerId.hexDump(config: simpleHexDumpConfig))")
        payloadOffset += 2
    default:
        print("Manufacturer-specific System Exclusive message")
        print("Manufacturer ID: Standard, \(String(format: "%02X", data[1]))")
    }
    
    let payloadLength = terminatorOffset - payloadOffset
    print("Payload: \(payloadLength) bytes")
    print(ByteArray(data[payloadOffset..<terminatorOffset]).hexDump(config: simpleHexDumpConfig))
}

public struct Manufacturer {
    public enum Identifier {
        case standard(Byte)
        case extended(ByteTriplet)
        case development
    }

    public enum Group {
        case unknown
        case american
        case europeanOrOther
        case japanese
        case other
    }
    
    public var identifier: Identifier
    
    public var displayName: String {
        let idString = self.identifier.description.filter { !$0.isWhitespace }
        if let info = manufacturerInformation[idString.uppercased()] {
            return info.0
        }
        return "unknown"
    }
    
    public var canonicalName: String {
        let idString = self.identifier.description.filter { !$0.isWhitespace }
        if let info = manufacturerInformation[idString.uppercased()] {
            return info.1
        }
        return "unknown"
    }
    
    public var group: Group {
        let idString = self.identifier.description.filter { !$0.isWhitespace }
        if let info = manufacturerInformation[idString.uppercased()] {
            return info.2
        }
        return .unknown
    }
}

typealias ManufacturerInformation = [String: (String, String, Manufacturer.Group)]

let manufacturerInformation: ManufacturerInformation = [
    "01": ("Sequential Circuits", "Sequential Circuits", .american),
    "00000E": ("Alesis", "Alesis Studio Electronics", .american),
    "00003B": ("MOTU", "Mark Of The Unicorn", .american),
    "40": ("Kawai", "Kawai Musical Instruments MFG. CO. Ltd", .japanese),
    "41": ("Roland", "Roland Corporation", .japanese),
    "42": ("KORG", "Korg Inc.", .japanese),
    "43": ("Yamaha", "Yamaha", .japanese),
]

extension Manufacturer.Group: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .american:
            return "American"
        case .japanese:
            return "Japanese"
        case .europeanOrOther:
            return "European or other"
        case .other:
            return "Other"
        }
    }
}

extension Manufacturer.Identifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .standard(let b):
            return String(format: "%02X", b)
        case .extended(let b):
            return String(format: "%02X %02X %02X", b.0, b.1, b.2)
        case .development:
            return "7D"
        }
    }
}

extension Manufacturer: CustomStringConvertible {
    public var description: String {
        var lines = [String]()

        let line1 = "Identifier: \(self.identifier)"
        lines.append(line1)
        
        var line2 = "Name      : "
        switch self.identifier {
        case .development:
            line2.append("Development")
        default:
            line2.append("\(self.displayName) (\(self.group))")
        }
        lines.append(line2)
        
        return lines.joined(separator: "\n")
    }
}

public enum Universal {
    public enum Kind {
        case nonRealTime
        case realTime
    }
    
    public typealias Header = (deviceChannel: Byte, subId1: Byte, subId2: Byte)
}

public typealias Payload = ByteArray

public enum Message {
    case universal(Universal.Kind, Universal.Header, Payload)
    case manufacturer(Manufacturer.Identifier, Payload)
}

extension Message {
    public init?(data: ByteArray) {
        guard data.count >= 4 else {
            return nil
        }
        guard data.last == 0xF7 else {
            return nil
        }
        let lastByteIndex = data.count - 1  // for dropping the SysEx terminator
        
        // Initialize the Universal SysEx message fields in advance, in case they are needed
        let header: Universal.Header = (deviceChannel: data[1], subId1: data[2], subId2: data[3])
        let payload = Payload(data[4..<lastByteIndex])
        
        switch data[0] {
        case 0x7E:
            self = .universal(.nonRealTime, header, payload)
        case 0x7F:
            self = .universal(.realTime, header, payload)
        case 0xF0:
            switch data[1] {
            case 0x00:
                self = .manufacturer(.extended((data[1], data[2], data[3])), payload)
            case 0x7D:
                self = .manufacturer(.development, Payload(data[2..<lastByteIndex]))
            default:
                self = .manufacturer(.standard(data[1]), Payload(data[2..<lastByteIndex]))
            }
        default:
            return nil
        }
    }
    
    public var payload: Payload {
        switch self {
        case .manufacturer(_, let payload):
            return payload
        case .universal(_, _, let payload):
            return payload
        }
    }
}

extension Message: CustomStringConvertible {
    public var description: String {
        var lines = [String]()
        
        switch self {
        case .universal(let kind, let header, let payload):
            var line = "Universal "
            switch kind {
            case .nonRealTime:
                line.append("Non-Real-time")
            case .realTime:
                line.append("Real-time")
            }
            line.append(" System Exclusive message")
            lines.append(line)
            
            lines.append("Device Ch: \(header.deviceChannel)")
            lines.append("Sub-ID #1: \(String(format: "%02X", header.subId1))")
            lines.append("Sub-ID #2: \(String(format: "%02X", header.subId2))")
            lines.append("Payload: \(payload.count) bytes")
            
        case .manufacturer(let id, let payload):
            lines.append("Manufacturer-specific System Exclusive message")
            
            let manufacturer = Manufacturer(identifier: id)
            lines.append("Manufacturer:\n\(manufacturer)")
            
            lines.append("Payload   : \(payload.count) bytes")
        }
        
        return lines.joined(separator: "\n")
    }
}
