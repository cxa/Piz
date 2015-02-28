//
//  EndRecord.swift
//  SimpleUnzipper
//
//  Created by CHEN Xian’an on 2/26/15.
//  Copyright (c) 2015 lazyapps. All rights reserved.
//

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

struct EndRecord {
  
  let numEntries: UInt16
  
  let centralDirectoryOffset: UInt32
  
}

extension EndRecord {
  
  static let signature: [UInt8] = [0x06, 0x05, 0x4b, 0x50]
  
  static func findEndRecordInBytes(bytes: UnsafePointer<UInt8>, length: Int) -> EndRecord? {
    var reader = BytesReader(bytes: bytes, index: length - 1 - signature.count)
    let maxTry = Int(UInt16.max)
    let minReadTo = max(length-maxTry, 0)
    let rng = 0..<4
    let indexFound: Bool = {
      while reader.index > minReadTo {
        for i in rng {
          if reader.byteb() != self.signature[i] { break }
          if i == rng.endIndex.predecessor() { reader.skip(1); return true }
        }
      }
      
      return false
    }()
    
    if !indexFound { return nil }
    reader.skip(4)
    let numDisks = reader.le16()
    reader.skip(2)
    reader.skip(2)
    let numEntries = reader.le16()
    reader.skip(4)
    let centralDirectoryOffset = reader.le32()
    if numDisks > 1 { return nil }
    return EndRecord(numEntries: numEntries, centralDirectoryOffset: centralDirectoryOffset)
  }
  
}