# SyxPack

Utilities for processing MIDI System Exclusive messages in Swift.

## Data structures

The SyxPack library contains several data structures that model MIDI
System Exclusive messages.

### Messages

System Exclusive messages are either universal or manufacturer-specific.
Universal SysEx messages are further divided into real-time and non-real-time
messages, while manufacturer-specific SysEx messages have an associated 
manufacturer identifier. Both universal and manufacturer-specific messages
have an associated payload, which is message specific.

### Manufacturers

MIDI equipment manufacturers have registered identifiers. The registry
is maintained by the MIDI Manufacturers Association (MMA), and is found 
on the MMA website: [Manufacturer SysEx ID Numbers](https://www.midi.org/specifications-old/item/manufacturer-id-numbers)

There are two kinds of manufacturer identifiers, standard and
extended. Standard identifiers consist of just one byte, while extended
identifiers consist of three bytes. In addition there is a special case of
standard identifier, intended for development or non-commercial use.

The `Manufacturer` struct represents the origin of a manufacturer-specific
System Exclusive message. Manufacturers are divided into groups based on 
their identifiers, as detailed on the MMA website.

The SyxPack library also has the display names for the registered MIDI
manufacturers. This can be useful if you need to identify SysEx messages
based only on their content.

### Helpers

The SyxPack library defines some useful helper types.

The `Byte` type is an alias for Swift's `UInt8` type, while `ByteArray` is
an alias for an `Array<UInt8>` or `[UInt8]`. These type aliases save you some
typing.

The `Byte` and `ByteArray` types have some useful extensions which allow you
easy access to the individual bits of a byte, or convert the contents of a 
`ByteArray` into representations commonly used in manufacturer-specific
SysEx messages.

In addition, there are extensions to produce a hexadecimal representation
or a "hex dump" of a byte array. The parameters of the dump are configurable.

## Test suite

The SyxPack library has a moderate amount of unit tests implemented using
Apple's XCTest library.

## The book

The development of SyxPack is described in the book
[_Bytes of Swift_](https://books.apple.com/us/book/bytes-of-swift/id1603196148?itsct=books_box_link&itscg=30200&ls=1&at=1l3vbcz&ct=github) by Jere Käpyaho, published on Apple Books 
by Conifer Productions Oy.
