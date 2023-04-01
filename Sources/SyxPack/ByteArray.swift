import Foundation

/// Array of Byte values.
public typealias ByteArray = [Byte]

extension ByteArray {
    /// Returns a string containing a hex dump of this byte array.
    /// The dump can be configured with the `config` parameter.
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

    /// Returns a source code dump of this byte array.
    /// The format of the dump is controlled by the `config` parameter.
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

extension ByteArray {
    /// Returns an unpacked version of this byte array. Assumes that the byte array is
    /// in the packed format used by many KORG synths.
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

    /// Returns a version of this byte array packed in the format used by many
    /// KORG synths.
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

/// Order of nybbles in a nybblified byte: low nybble or high nybble first.
public enum NybbleOrder {
    case lowFirst
    case highFirst
}

extension ByteArray {
    /// Returns a nybblified version of this byte array. The nybble order is determined by `order`.
    public func nybblified(order: NybbleOrder = .highFirst) -> ByteArray {
        var result = ByteArray()
        self.forEach { b in
            let n = b.nybbles
            if order == .highFirst {
                result.append(n.high)
                result.append(n.low)
            }
            else {
                result.append(n.low)
                result.append(n.high)
            }
        }
        return result
    }
    
    /// Returns a denybblified version of this byte array, or `nil` if the length of the array is odd.
    public func denybblified(order: NybbleOrder = .highFirst) -> ByteArray? {
        guard self.count % 2 == 0 else {
            return nil
        }
        
        var result = ByteArray()
        
        var index = 0
        var offset = 0
        let count = self.count / 2
        while index < count {
            result.append(order == .highFirst ?
                Byte(nybbles: (high: self[offset], low: self[offset + 1])) :
                Byte(nybbles: (high: self[offset + 1], low: self[offset])))
            index += 1
            offset += 2
        }

        return result
    }
}
