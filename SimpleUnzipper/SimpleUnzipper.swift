//
//  SimpleUnzipper.swift
//  SimpleUnzipper
//
//  Created by CHEN Xian’an on 2/25/15.
//  Copyright (c) 2015 lazyapps. All rights reserved.
//

import Foundation

/// Use static method `createWithURL` or `createWithData` to create an instance
public struct SimpleUnzipper {
  
  public let data: NSData

  public init?(data: NSData) {
    let bytes = unsafeBitCast(data.bytes, UnsafePointer<UInt8>.self)
    let len = data.length
    guard
      let rec = EndRecord.findEndRecordInBytes(bytes, length: len),
      let dirs = CentralDirectory.findCentralDirectoriesInBytes(bytes, length: len, withEndRecrod: rec)
    else {
      return nil
    }

    self.data = data
    _bytes = bytes
    _cdirs = dirs
  }

  public init?(fileURL: NSURL) {
    guard let data = NSData(contentsOfURL: fileURL) else { return nil }
    self.init(data: data)
  }
  
  private let _bytes: UnsafePointer<UInt8>

  private let _cdirs: [String: CentralDirectory]
  
}

public extension SimpleUnzipper {

  /// Retrive file names inside the zip
  var files: [String] {
    return Array(_cdirs.keys)
  }
  
  /// Test if `file` exists
  func containsFile(file: String) -> Bool {
    return _cdirs[file] != nil
  }
  
  /// Get data for `file`
  func dataForFile(file: String) -> NSData? {
    if let cdir = _cdirs[file] {
      return Uncompressor.uncompressWithCentralDirectory(cdir, fromBytes: _bytes)
    }
    
    return nil
  }

  subscript(file: String) -> NSData? {
    return dataForFile(file)
  }

}
