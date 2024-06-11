import ByteKit

/// Protocol for MIDI System Exclusive data.
public protocol SystemExclusiveData {
    /// Gets the data as a byte array.
    func asData() -> ByteArray
    
    /// Gets the length of the data.
    var dataLength: Int { get }
}
