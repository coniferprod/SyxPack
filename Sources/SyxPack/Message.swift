import Foundation

/// Represents a Universal System Exclusive message.
public enum Universal: Equatable {
    /// The kind of the universal message.
    public enum Kind {
        case nonRealTime
        case realTime
    }
    
    /// The header of a universal message.
    public struct Header {
        let deviceChannel: Byte
        let subId1: Byte
        let subId2: Byte
    }
}

/// Convenience definition for message payload.
public typealias Payload = ByteArray

/// Represents a MIDI System Exclusive message.
public enum Message {
    case universal(Universal.Kind, Universal.Header, Payload)
    case manufacturerSpecific(Manufacturer, Payload)
}

extension Message {
    /// Initializes a message from the System Exclusive data bytes.
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
        
        switch data[1] {
        case 0x7D:
            self = .manufacturerSpecific(.development, getPayload())
        case 0x7E:
            self = .universal(.nonRealTime, getHeader(), getPayload(startIndex: 4))
        case 0x7F:
            self = .universal(.realTime, getHeader(), getPayload(startIndex: 4))
        case 0x00:
            self = .manufacturerSpecific(
                Manufacturer.extended((data[1], data[2], data[3])),
                getPayload(startIndex: 4))
        default:
            self = .manufacturerSpecific(Manufacturer.standard(data[1]), getPayload())
        }
    }
    
    /// Gets the payload of the message.
    public var payload: Payload {
        switch self {
        case .manufacturerSpecific(_, let data):
            return data
        case .universal(_, _, let data):
            return data
        }
    }
    
    /// Gets the message bytes, complete with delimiters.
    public func asData() -> ByteArray {
        var result = ByteArray()
        
        result.append(initiator)
        
        switch self {
        case .manufacturerSpecific(let manufacturer, let payload):
            result.append(contentsOf: manufacturer.identifier)
            result.append(contentsOf: payload)
            
        case .universal(let kind, let header, let payload):
            switch kind {
            case .nonRealTime:
                result.append(0x7E)
                
            case .realTime:
                result.append(0x7F)
            }
            result.append(header.deviceChannel)
            result.append(header.subId1)
            result.append(header.subId2)
            result.append(contentsOf: payload)
        }

        result.append(terminator)

        return result
    }
}

extension Message: CustomStringConvertible {
    /// Gets a printable string representation of the message.
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
            
        case .manufacturerSpecific(let manufacturer, let payload):
            lines.append("Manufacturer-specific System Exclusive message")
            lines.append("Manufacturer:\n\(manufacturer)")
            lines.append("Payload   : \(payload.count) bytes")
        }
        
        return lines.joined(separator: "\n")
    }
}
