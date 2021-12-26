import Foundation

public typealias Byte = UInt8
public typealias ByteArray = [Byte]
public typealias ByteTriplet = (Byte, Byte, Byte)


extension Data {
    public var bytes: ByteArray {
        var byteArray = ByteArray(repeating: 0, count: self.count)
        self.copyBytes(to: &byteArray, count: self.count)
        return byteArray
    }
}

extension Byte {
    public mutating func setBit(_ position: Int) {
        self |= 1 << position
    }

    public mutating func unsetBit(_ position: Int) {
        self &= ~(1 << position)
    }

    public func isBitSet(_ position: Int) -> Bool {
        return (self & (1 << position)) != 0
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

extension ByteArray {
    public func hexDump(config: HexDumpConfig = .defaultConfig) -> String {
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

    public func sourceDump(config: SourceDumpConfig = .defaultConfig) -> String {
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

public struct Manufacturer {
    public enum Identifier { /*: Equatable {
        public static func == (lhs: Manufacturer.Identifier, rhs: Manufacturer.Identifier) -> Bool {
            switch (lhs, rhs) {
            case (let .standard(lhsByte), let .standard(rhsByte)):
                return lhsByte == rhsByte
            case (let .extended(lhsByteTriplet), let .extended(rhsByteTriplet)):
                return lhsByteTriplet.0 == rhsByteTriplet.0 &&
                       lhsByteTriplet.1 == rhsByteTriplet.1 &&
                       lhsByteTriplet.2 == rhsByteTriplet.2
            default:
                return lhs == rhs
            }
        }
        */
    
        case standard(Byte)
        case extended(ByteTriplet)
        case development
    }

    public enum Group: Equatable {
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
    
    public static let kawai = Manufacturer(identifier: .standard(0x40))
    public static let roland = Manufacturer(identifier: .standard(0x41))
    public static let korg = Manufacturer(identifier: .standard(0x42))
    public static let yamaha = Manufacturer(identifier: .standard(0x43))
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

public enum Universal: Equatable {
    public enum Kind {
        case nonRealTime
        case realTime
    }
    
    public struct Header {
        let deviceChannel: Byte
        let subId1: Byte
        let subId2: Byte
    }
    //public typealias Header = (deviceChannel: Byte, subId1: Byte, subId2: Byte)
}

public typealias Payload = ByteArray

public enum Message {
    case universal(Universal.Kind, Universal.Header, Payload)
    case manufacturer(Manufacturer.Identifier, Payload)
}

extension Message {
    public init?(data: ByteArray) {
        func getPayload(startIndex: Int = 2) -> Payload {
            let endIndex = data.count - 1
            return Payload(data[startIndex..<endIndex])
        }
        
        func getHeader() -> Universal.Header {
            return Universal.Header(deviceChannel: data[2], subId1: data[3], subId2: data[4])
        }
        
        guard data.count >= 5 else {
            return nil
        }
        guard data.first == 0xF0 else {
            return nil
        }
        guard data.last == 0xF7 else {
            return nil
        }
        
        //let header: Universal.Header = (deviceChannel: data[2], subId1: data[3], subId2: data[4])
        
        switch data[1] {
        case 0x7D:
            self = .manufacturer(.development, getPayload())
        case 0x7E:
            self = .universal(.nonRealTime, getHeader(), getPayload(startIndex: 4))
        case 0x7F:
            self = .universal(.realTime, getHeader(), getPayload(startIndex: 4))
        case 0x00:
            self = .manufacturer(.extended((data[1], data[2], data[3])), getPayload(startIndex: 4))
        default:
            self = .manufacturer(.standard(data[1]), getPayload())
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

/*
extension Message: Equatable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        switch lhs {
        case .universal(let kind, let header, let payload):
            return kind == rhs.
        case .manufacturer(let identifier, let payload):
            return true
        }
    }
}
*/

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

extension ByteArray {
    public func unpacked() -> ByteArray {
        func unpackChunk(data: ByteArray) -> ByteArray {
            let indexByte = data.first!
            let dataBytes = data.suffix(from: 1)

            var result = ByteArray()

            for (index, value) in dataBytes.enumerated() {
                var b: Byte = value
                if indexByte.isBitSet(index) {
                    b.setBit(7)
                }
                result.append(b)
            }

            return result
        }

        let chunkSize = 8
        let chunks = self.chunked(into: chunkSize)
        
        var result = ByteArray()
        chunks.forEach { chunk in
            result.append(contentsOf: unpackChunk(data: chunk))
        }

        return result
    }
    
    public func packed() -> ByteArray {
        func makeIndexByte(buf: ByteArray) -> Byte {
            var bits = [Bool]()
            buf.forEach {
                bits.append($0.isBitSet(7))
            }
            var result: Byte = 0
            for (index, bit) in bits.enumerated() {
                if bit {
                    result.setBit(index)
                }
            }
            return result
        }

        func packChunk(data: ByteArray) -> ByteArray {
            var d = ByteArray()
            d.append(makeIndexByte(buf: data))
            data.forEach { b in
                d.append(b & 0x7f)
            }
            return d
        }

        let chunkSize = 7
        let chunks = self.chunked(into: chunkSize)
        var result = ByteArray()
        chunks.forEach { chunk in
            result.append(contentsOf: packChunk(data: chunk))
        }

        return result
    }
}
