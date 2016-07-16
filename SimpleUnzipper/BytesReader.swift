//
//  BytesReader.swift
//  SimpleUnzipper
//
//  Created by CHEN Xian’an on 2/26/15.
//  Copyright (c) 2015 lazyapps. All rights reserved.
//

import Foundation

struct BytesReader {

  let bytes: UnsafePointer<UInt8>

  var index: Int

  init(bytes b: UnsafePointer<UInt8>, index i: Int) {
    bytes = b
    index = i
  }

}

extension BytesReader {

  mutating func skip(_ dist: Int, backward: Bool = false) {
    self.index = backward ? self.index - dist : self.index + dist
  }

  mutating func skipb(_ dist: Int) {
    skip(dist, backward: true)
  }

  mutating func byte(_ readBackward: Bool = false) -> UInt8 {
    let result = bytes[index]
    self.index = readBackward ? self.index-1 : self.index+1
    return result
  }

  mutating func byteb() -> UInt8 {
    return byte(true)
  }

  mutating func le16(_ readBackward: Bool = false) -> UInt16 {
    let rng = index..<index+2
    let result = rng.reduce(UInt16.min) { $0 + UInt16(bytes[$1]) << UInt16(($1 - rng.startIndex) * 8) }
    index = readBackward ? rng.startIndex-1 : rng.endIndex
    return result
  }

  mutating func le16b() -> UInt16 {
    return le16(true)
  }

  mutating func le32(_ readBackward: Bool = false) -> UInt32 {
    let rng = index..<index+4
    let result = rng.reduce(UInt32.min) { $0 + UInt32(bytes[$1]) << UInt32(($1 - rng.startIndex) * 8) }
    index = readBackward ? rng.startIndex-1 : rng.endIndex
    return result
  }

  mutating func le32b() -> UInt32 {
    return le32(true)
  }

  mutating func string(_ len: Int) -> String? {
    let buffp = UnsafeBufferPointer<UInt8>(start: bytes.advanced(by: index), count: len)
    let s = String(bytes: buffp.makeIterator(), encoding: String.Encoding.utf8)
    index += len
    return s
  }

}
