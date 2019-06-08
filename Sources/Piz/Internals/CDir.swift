//
//  CDir.swift
//  
//
//  Created by CHEN Xian-an on 2019/6/8.
//

enum CompressionMethod {
  case None
  case Deflate

  init(_ i: UInt16) {
    self =  i == 8 ? .Deflate : .None
  }
}

struct CDir {
  let bytes: UnsafePointer<UInt8>
  let compressionMethod: CompressionMethod
  let compressedSize: UInt64
  let uncompressedSize: UInt64
  let fileName: String
  let localFileHeaderOffset: UInt64
}

extension CDir {
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
    var reader = ByteReader(bytes: bytes, index: Int(localFileHeaderOffset))
    reader.skip(4 + 2 * 5 + 4 * 3)
    let fnLen = reader.le16()
    let efLen = reader.le16()
    reader.skip(Int(fnLen + efLen))
    return reader.index
  }
}

extension CDir {
  static let signature: UInt32 = 0x02014b50

  static func findCDirs(inBytes bytes: UnsafePointer<UInt8>, length: Int, record: EndRecord) -> [String: CDir]? {
    var reader = ByteReader(bytes: bytes, index: Int(record.centralDirectoryOffset))
    var dirs = [String: CDir]()
    for _ in 0..<record.numEntries {
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

      // need to fetch 'em in extra field in Zip64
      var cSize: UInt64 = 0
      var ucSize: UInt64 = 0
      var offset: UInt64 = 0

      let sign = reader.le32()
      if sign != signature { return dirs }
      reader.skip(2 + 2 + 2)
      let cMethodNum = reader.le16()
      reader.skip(2 + 2 + 4)
      if !record.isZip64 {
        cSize = UInt64(reader.le32())
        ucSize = UInt64(reader.le32())
      } else {
        reader.skip(4 + 4)
      }
      let fnLen = reader.le16()
      let efLen = reader.le16()
      let fcLen = reader.le16()
      reader.skip(2 + 2 + 4)
      if !record.isZip64 { offset = UInt64(reader.le32()) }
      else { reader.skip(4) }
      if let fn = reader.string(Int(fnLen)) {
        let cMethod = CompressionMethod(cMethodNum)
        if record.isZip64 {
          /*
           Value      Size       Description
           -----      ----       -----------
   (ZIP64) 0x0001     2 bytes    Tag for this "extra" block type
           Size       2 bytes    Size of this "extra" block
           Original
           Size       8 bytes    Original uncompressed file size
           Compressed
           Size       8 bytes    Size of compressed data
           Relative Header
           Offset     8 bytes    Offset of local header record
           Disk Start
           Number     4 bytes    Number of the disk on which
           this file starts
           */
          reader.skip(2 + 2)
          ucSize = reader.le64()
          cSize = reader.le64()
          offset = reader.le64()
          reader.skipb(8 + 8 + 8 + 2 + 2)
        }

        dirs[fn] = CDir(bytes: bytes, compressionMethod: cMethod, compressedSize: cSize, uncompressedSize: ucSize, fileName: fn, localFileHeaderOffset: offset)
      }
      reader.skip(Int(efLen + fcLen))
    }

    return dirs.count > 0 ? dirs : nil
  }
}
