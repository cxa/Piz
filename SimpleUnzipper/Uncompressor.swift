//
//  Uncompressor.swift
//  SimpleUnzipper
//
//  Created by CHEN Xian’an on 2/27/15.
//  Copyright (c) 2015 lazyapps. All rights reserved.
//

import Foundation
import zlib

struct Uncompressor {

  static func uncompressWithCentralDirectory(_ cdir: CentralDirectory, fromBytes bytes: UnsafePointer<UInt8>) -> Data? {
    let offsetBytes = bytes.advanced(by: Int(cdir.dataOffset))
    let offsetMBytes = UnsafeMutablePointer<UInt8>(offsetBytes)
    let len = Int(cdir.uncompressedSize)
    let out = UnsafeMutablePointer<UInt8>(allocatingCapacity: len)
    switch cdir.compressionMethod {
    case .none:
      out.assignFrom(offsetMBytes, count: len)
    case .deflate:
      var strm = z_stream()
      let initStatus = inflateInit2_(&strm, -MAX_WBITS, (ZLIB_VERSION as NSString).utf8String, Int32(sizeof(z_stream.self)))
      if initStatus != Z_OK { out.deinitialize(); return nil }
      strm.avail_in = cdir.compressedSize
      strm.next_in = offsetMBytes
      strm.avail_out = cdir.uncompressedSize
      strm.next_out = out
      if inflate(&strm, Z_NO_FLUSH) != Z_STREAM_END { out.deinitialize(); return nil }
      if inflateEnd(&strm) != Z_OK { out.deinitialize(); return nil }
    }

    return Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(out), count: len, deallocator: .free)
  }

}
