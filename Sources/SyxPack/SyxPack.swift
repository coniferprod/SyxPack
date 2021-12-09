import Foundation

typealias Byte = UInt8
typealias ByteArray = [Byte]

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
    
    switch data[1] {
    case 0x7E:
        print("Universal Non-Realtime System Exclusive message")
    case 0x7F:
        print("Universal Realtime System Exclusive message")
    default:
        print("Manufacturer ID:", separator: " ")
        switch data[2] {
        case 0x00:
            let manufacturerId: ByteArray = [
                data[2], data[3], data[4]
            ]
            print("Extended, \(manufacturerId.hexDump())")
            payloadOffset += 2
        case 0x7D:
            print("Development ")
        default:
            print("Standard, \(String(format: "%02X", data[1]))")
        }
    }
    
    let payloadLength = terminatorOffset - payloadOffset
    print("Payload: \(payloadLength) bytes")
}
