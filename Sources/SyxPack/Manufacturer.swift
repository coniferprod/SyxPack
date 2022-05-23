import Foundation

public typealias ByteTriplet = (Byte, Byte, Byte)

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
    
    public static let kawai = Manufacturer(identifier: .standard(0x40))
    public static let roland = Manufacturer(identifier: .standard(0x41))
    public static let korg = Manufacturer(identifier: .standard(0x42))
    public static let yamaha = Manufacturer(identifier: .standard(0x43))
    public static let alesis = Manufacturer(identifier: .extended((0x00, 0x00, 0x0E)))
    
    public static let development = Manufacturer(identifier: .development)
}

// MARK: - Equatable

extension Manufacturer: Equatable { }
extension Manufacturer.Identifier: Equatable { }
extension Manufacturer.Group: Equatable { }

// Explicitly implementing the equals operator for Manufacturer.Identifier
// because the some of its variants have associated values.
public func ==(lhs: Manufacturer.Identifier, rhs: Manufacturer.Identifier) -> Bool {
    switch (lhs, rhs) {
    case (let .standard(lhsByte), let .standard(rhsByte)):
        return lhsByte == rhsByte
    case (let .extended(lhsByteTriplet), let .extended(rhsByteTriplet)):
        return lhsByteTriplet.0 == rhsByteTriplet.0 &&
               lhsByteTriplet.1 == rhsByteTriplet.1 &&
               lhsByteTriplet.2 == rhsByteTriplet.2
    case (.development, .development):
        return true
    default:
        return false
    }
}

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
