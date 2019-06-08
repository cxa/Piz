//
//  ByteReader.swift
//  
//
//  Created by CHEN Xian-an on 2019/6/8.
//

struct ByteReader {
  let bytes: UnsafePointer<UInt8>
  var index: Int

  init(bytes b: UnsafePointer<UInt8>, index i: Int) {
    bytes = b
    index = i
  }
}

extension ByteReader {
  mutating func skip(_ dist: Int, backward: Bool = false) {
    self.index = backward ? self.index - dist : self.index + dist
  }

  mutating func skipb(_ dist: Int) {
    skip(dist, backward: true)
  }

  mutating func byte(readBackward: Bool = false) -> UInt8 {
    let result = bytes[index]
    self.index = readBackward ? self.index-1 : self.index+1
    return result
  }

  mutating func byteb() -> UInt8 {
    return byte(readBackward: true)
  }

  mutating func le16(readBackward: Bool = false) -> UInt16 {
    let rng = index..<index+2
    let result = rng.reduce(UInt16.min) { $0 + UInt16(bytes[$1]) << UInt16(($1 - rng.startIndex) * 8) }
    index = readBackward ? rng.startIndex-1 : rng.endIndex
    return result
  }

  mutating func le16b() -> UInt16 {
    return le16(readBackward: true)
  }

  mutating func le32(readBackward: Bool = false) -> UInt32 {
    let rng = index..<index+4
    let result = rng.reduce(UInt32.min) { $0 + UInt32(bytes[$1]) << UInt32(($1 - rng.startIndex) * 8) }
    index = readBackward ? rng.startIndex-1 : rng.endIndex
    return result
  }

  mutating func le32b() -> UInt32 {
    return le32(readBackward: true)
  }

  mutating func le64(readBackward: Bool = false) -> UInt64 {
    let rng = index..<index+8
    let result = rng.reduce(UInt64.min) { $0 + UInt64(bytes[$1]) << UInt64(($1 - rng.startIndex) * 8) }
    index = readBackward ? rng.startIndex-1 : rng.endIndex
    return result
  }

  mutating func le64b() -> UInt64 {
    return le64(readBackward: true)
  }

  mutating func string(_ len: Int) -> String? {
    let chars = UnsafeMutablePointer(mutating: bytes.advanced(by: index))
    let s = String(bytesNoCopy: chars, length: len, encoding: .utf8, freeWhenDone: false)
    index += len
    return s
  }
}
