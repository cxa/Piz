//
//  Uncompressor.swift
//  
//
//  Created by CHEN Xian-an on 2019/6/8.
//

import Foundation
import zlib

enum Uncompressor {}

extension Uncompressor {
  static func uncompressWithCentralDirectory(cdir: CDir, fromBytes bytes: UnsafePointer<UInt8>) -> Data? {
    let offsetBytes = bytes.advanced(by: cdir.dataOffset)
    let len = Int(cdir.uncompressedSize)
    let offsetMBytes = UnsafeMutablePointer<UInt8>(mutating: offsetBytes)
    let out = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
    switch cdir.compressionMethod {
    case .None:
      out.assign(from: offsetMBytes, count: len)
    case .Deflate:
      var strm = z_stream()
      let initStatus = inflateInit2_(&strm, -MAX_WBITS, ZLIB_VERSION.cString(using: .utf8)!, Int32(MemoryLayout<z_stream>.size))
      if initStatus != Z_OK { out.deallocate(); return nil }
      strm.avail_in = UInt32(cdir.compressedSize)
      strm.next_in = offsetMBytes
      strm.avail_out = UInt32(cdir.uncompressedSize)
      strm.next_out = out
      if inflate(&strm, Z_NO_FLUSH) != Z_STREAM_END { out.deallocate(); return nil }
      if inflateEnd(&strm) != Z_OK { out.deallocate(); return nil }
    }

    return Data(bytesNoCopy: out, count: len, deallocator: .free)
  }
}
