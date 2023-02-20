import Foundation

/// Convenience type alias for a byte
public typealias Byte = UInt8

/// Convenience type for a named tuple of the nybbles in a byte
public typealias Nybbles = (high: Byte, low: Byte)

/// Enumeration for bits
public enum Bit: Byte {
    case zero
    case one
}

extension Bit: CustomStringConvertible {
    /// Returns a string representation of this bit
    public var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}

/// Type alias for an array of bits
public typealias Bits = [Bit]

extension Bits {
    /// Converts the bits in this array to a byte.
    public func byte() -> Byte {
        var value: Byte = 0x00
        // Take only the first eight bits, in case there are more.
        for (position, bit) in self.prefix(8).enumerated() {
            if bit == .one {
                value.setBit(position)
            }
        }
        return value
    }
}

extension Byte {
     /// Converts this byte into a bit array.
    public func bits() -> Bits {
        var allBits = Bits(repeating: .zero, count: 8)
        for i in 0..<8 {
            if self.isBitSet(i) {
                allBits[i] = .one
            }
        }
        return allBits
    }
    
    /// Replaces the bits in `range` of this byte with with `value`.
    public mutating func replaceBits(_ range: ClosedRange<Int>, with value: Byte) {
        var allBits = self.bits()  // always has eight bits
        let valueBitString = String(value, radix: 2)  // convert to find minimum length
        let valueBits = value.bits().dropLast(valueBitString.count)  // drop trailing zero bytes
        allBits.replaceSubrange(range, with: valueBits)  // replace the bit field
        self = allBits.byte()
    }
}

// MARK: - Bit-related extensions to Byte

extension Byte {
    /// Sets the bit at `position`.
    public mutating func setBit(_ position: Int) {
        guard position >= 0 && position < 8 else {
            return
        }
        self |= 1 << position
    }

    /// Clears the bit at `position`.
    public mutating func clearBit(_ position: Int) {
        guard position >= 0 && position < 8 else {
            return
        }
        self &= ~(1 << position)
    }

    /// Returns `true` if the bit at `position` is set, `false` otherwise.
    public func isBitSet(_ position: Int) -> Bool {
        guard position >= 0 && position < 8 else {
            return false
        }
        return (self & (1 << position)) != 0
    }
}

// MARK: - Nybble-related extensions to Byte

extension Byte {
    /// Returns the high nybble (top four bits) of this byte.
    public var highNybble: Byte {
        return (self & 0xf0) >> 4
    }
    
    /// Returns the low nybble (bottom foor bits) of this byte.
    public var lowNybble: Byte {
        return self & 0x0f
    }
    
    /// Returns the high and low nybbles of this byte as a named tuple.
    public var nybbles: Nybbles {
        return (high: self.highNybble, low: self.lowNybble)
    }
    
    /// Initializes a byte from two nybbles.
    public init(nybbles: Nybbles) {
        self = (nybbles.high << 4) | (nybbles.low)
    }
}
