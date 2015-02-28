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
  
  static func uncompressWithCentralDirectory(cdir: CentralDirectory, fromBytes bytes: UnsafePointer<UInt8>) -> NSData? {
    let offsetBytes = bytes.advancedBy(Int(cdir.dataOffset))
    let offsetMBytes = UnsafeMutablePointer<UInt8>(offsetBytes)
    let len = Int(cdir.uncompressedSize)
    let out = UnsafeMutablePointer<UInt8>.alloc(len)
    switch cdir.compressionMethod {
    case .None:
      out.assignFrom(offsetMBytes, count: len)
    case .Deflate:
      var strm = z_stream()
      let initStatus = inflateInit2_(&strm, -MAX_WBITS, (ZLIB_VERSION as NSString).UTF8String, Int32(sizeof(z_stream)))
      if initStatus != Z_OK { out.destroy(); return nil }
      strm.avail_in = cdir.compressedSize
      strm.next_in = offsetMBytes
      strm.avail_out = cdir.uncompressedSize
      strm.next_out = out
      if inflate(&strm, Z_NO_FLUSH) != Z_STREAM_END { out.destroy(); return nil }
      if inflateEnd(&strm) != Z_OK { out.destroy(); return nil }
    }
    
    return NSData(bytesNoCopy: out, length: len, freeWhenDone: true)
  }
  
}