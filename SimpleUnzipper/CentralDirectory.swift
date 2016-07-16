//
//  CentralDirectory.swift
//  SimpleUnzipper
//
//  Created by CHEN Xian’an on 2/27/15.
//  Copyright (c) 2015 lazyapps. All rights reserved.
//

/*
 central file header signature   4 bytes  (0x02014b50)
 version made by                 2 bytes
 version needed to extract       2 bytes
 general purpose bit flag        2 bytes
 compression method              2 bytes
 last mod file time              2 bytes
 last mod file date              2 bytes
 crc-32                          4 bytes
 compressed size                 4 bytes
 uncompressed size               4 bytes
 file name length                2 bytes
 extra field length              2 bytes
 file comment length             2 bytes
 disk number start               2 bytes
 internal file attributes        2 bytes
 external file attributes        4 bytes
 relative offset of local header 4 bytes

 file name (variable size)
 extra field (variable size)
 file comment (variable size)
 */

enum CompressionMethod {
  case None
  case Deflate

  init?(_ i: UInt16) {
    if i == 0 {
      self = .None
    } else if i == 8 {
      self = .Deflate
    } else {
      return nil
    }
  }

}

struct CentralDirectory {

  let bytes: UnsafePointer<UInt8>

  let compressionMethod: CompressionMethod

  let compressedSize: UInt32

  let uncompressedSize: UInt32

  let fileName: String

  let localFileHeaderOffset: UInt32

}

extension CentralDirectory {

  /*
   local file header signature     4 bytes  (0x04034b50)
   version needed to extract       2 bytes
   general purpose bit flag        2 bytes
   compression method              2 bytes
   last mod file time              2 bytes
   last mod file date              2 bytes
   crc-32                          4 bytes
   compressed size                 4 bytes
   uncompressed size               4 bytes
   file name length                2 bytes
   extra field length              2 bytes
   */

  var dataOffset: Int {
    var reader = BytesReader(bytes: bytes, index: Int(localFileHeaderOffset))
    reader.skip(4 + 2 * 5 + 4 * 3)
    let fnLen = reader.le16()
    let efLen = reader.le16()
    reader.skip(Int(fnLen + efLen))
    return reader.index
  }

}

extension CentralDirectory {

  static let signature: UInt32 = 0x02014b50

  static func findCentralDirectoriesInBytes(bytes: UnsafePointer<UInt8>, length: Int, withEndRecrod er: EndRecord) -> [String: CentralDirectory]? {
    var reader = BytesReader(bytes: bytes, index: Int(er.centralDirectoryOffset))
    var dirs = [String: CentralDirectory]()
    for _ in 0..<er.numEntries {
      let sign = reader.le32()
      if sign != signature { return dirs }
      reader.skip(2 + 2 + 2)
      let cMethodNum = reader.le16()
      reader.skip(2 + 2 + 4)
      let cSize = reader.le32()
      let ucSize = reader.le32()
      let fnLen = reader.le16()
      let efLen = reader.le16()
      let fcLen = reader.le16()
      reader.skip(2 + 2 + 4)
      let offset = reader.le32()
      if let fn = reader.string(Int(fnLen)),
        let cMethod = CompressionMethod(cMethodNum) {
        dirs[fn] = CentralDirectory(bytes: bytes, compressionMethod: cMethod, compressedSize: cSize, uncompressedSize: ucSize, fileName: fn, localFileHeaderOffset: offset)
      }

      reader.skip(Int(efLen + fcLen))
    }
    
    return dirs.count > 0 ? dirs : nil
  }
  
}
