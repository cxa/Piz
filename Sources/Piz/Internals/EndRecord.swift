//
//  EndRecord.swift
//  
//
//  Created by CHEN Xian-an on 2019/6/8.
//

struct EndRecord {
  let numEntries: UInt64
  let centralDirectoryOffset: UInt64
  let isZip64: Bool
}

extension EndRecord {
  static let signature: [UInt8]   = [0x06, 0x05, 0x4b, 0x50]
  static let signature64: [UInt8] = [0x06, 0x06, 0x4b, 0x50]

  private static func readToEndSignature(_ reader: inout ByteReader, _ length: Int, _ sign: [UInt8]) -> Bool {
    let maxTry = Int(UInt16.max)
    let minReadTo = max(length-maxTry, 0)
    let rng = 0..<4
    while reader.index > minReadTo {
      for i in rng {
        if reader.byteb() != sign[i] { break }
        if i == rng.count - 1 {
          reader.skip(1)
          return true
        }
      }
    }
    return false
  }

  /*
   end of central dir signature    4 bytes  (0x06054b50)
   number of this disk             2 bytes
   number of the disk with the
   start of the central directory  2 bytes
   total number of entries in the
   central directory on this disk  2 bytes
   total number of entries in
   the central directory           2 bytes
   size of the central directory   4 bytes
   offset of start of central
   directory with respect to
   the starting disk number        4 bytes
   .ZIP file comment length        2 bytes
   .ZIP file comment       (variable size)
   */
  static func findEndRecord(inBytes bytes: UnsafePointer<UInt8>, length: Int) -> EndRecord? {
    var reader = ByteReader(bytes: bytes, index: length - 1 - signature.count)
    if !readToEndSignature(&reader, length, signature) { return nil }
    reader.skip(4 + 2 + 2 + 2)
    let numEntries = reader.le16()
    reader.skip(4)
    let centralDirectoryOffset = reader.le32()
    return EndRecord(numEntries: UInt64(numEntries), centralDirectoryOffset: UInt64(centralDirectoryOffset), isZip64: false)
  }

  /*
   zip64 end of central dir
   signature                       4 bytes  (0x06064b50)
   size of zip64 end of central
   directory record                8 bytes
   version made by                 2 bytes
   version needed to extract       2 bytes
   number of this disk             4 bytes
   number of the disk with the
   start of the central directory  4 bytes
   total number of entries in the
   central directory on this disk  8 bytes
   total number of entries in the
   central directory               8 bytes
   size of the central directory   8 bytes
   offset of start of central
   directory with respect to
   the starting disk number        8 bytes
   zip64 extensible data sector    (variable size)
   */
  static func findEndRecord64(inBytes bytes: UnsafePointer<UInt8>, length: Int) -> EndRecord? {
    var reader = ByteReader(bytes: bytes, index: length - 1 - signature64.count)
    if !readToEndSignature(&reader, length, signature64) { return nil }
    reader.skip(4 + 8 + 2 + 2 + 4 + 4 + 8)
    let numEntries = reader.le64()
    reader.skip(8)
    let centralDirectoryOffset = reader.le64()
    return EndRecord(numEntries: numEntries, centralDirectoryOffset: centralDirectoryOffset, isZip64: true)
  }
}
