import Foundation

public typealias Byte = UInt8
public typealias Nybbles = (high: Byte, low: Byte)

extension Byte {
    public mutating func setBit(_ position: Int) {
        self |= 1 << position
    }

    public mutating func clearBit(_ position: Int) {
        self &= ~(1 << position)
    }

    public func isBitSet(_ position: Int) -> Bool {
        return (self & (1 << position)) != 0
    }
}

extension Byte {
    public var highNybble: Byte {
        return (self & 0xf0) >> 4
    }
    
    public var lowNybble: Byte {
        return self & 0x0f
    }
    
    public var nybbles: Nybbles {
        return (high: self.highNybble, low: self.lowNybble)
    }
    
    public init(nybbles: Nybbles) {
        self = (nybbles.high << 4) | (nybbles.low)
    }
}
