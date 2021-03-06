import Foundation

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
}

public typealias Payload = ByteArray

public enum Message {
    case universal(Universal.Kind, Universal.Header, Payload)
    case manufacturer(Manufacturer, Payload)
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
        
        switch data[1] {
        case 0x7D:
            self = .manufacturer(.development, getPayload())
        case 0x7E:
            self = .universal(.nonRealTime, getHeader(), getPayload(startIndex: 4))
        case 0x7F:
            self = .universal(.realTime, getHeader(), getPayload(startIndex: 4))
        case 0x00:
            self = .manufacturer(Manufacturer(identifier: .extended((data[1], data[2], data[3]))), getPayload(startIndex: 4))
        default:
            self = .manufacturer(Manufacturer(identifier: .standard(data[1])), getPayload())
        }
    }
    
    public var payload: Payload {
        switch self {
        case .manufacturer(_, let data):
            return data
        case .universal(_, _, let data):
            return data
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
            
        case .manufacturer(let manufacturer, let payload):
            lines.append("Manufacturer-specific System Exclusive message")
            lines.append("Manufacturer:\n\(manufacturer)")
            lines.append("Payload   : \(payload.count) bytes")
        }
        
        return lines.joined(separator: "\n")
    }
}
