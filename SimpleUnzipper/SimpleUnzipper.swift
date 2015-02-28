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
  
  let data: NSData
  
  private let _bytes: UnsafePointer<UInt8>

  private let _cdirs: [String: CentralDirectory]
  
}

public extension SimpleUnzipper {
  
  /// Create an unzipper with an URL, shortcut for `createWithData`
  static func createWithURL(zipFileURL: NSURL) -> SimpleUnzipper? {
    if let data = NSData(contentsOfURL: zipFileURL) {
      return createWithData(data)
    }
    
    return nil
  }
  
  /// Create an unzipper with given `NSData`
  static func createWithData(data: NSData) -> SimpleUnzipper? {
    let bytes = unsafeBitCast(data.bytes, UnsafePointer<UInt8>.self)
    let len = data.length
    if let rec = EndRecord.findEndRecordInBytes(bytes, length: len),
       let dirs = CentralDirectory.findCentralDirectoriesInBytes(bytes, length: len, withEndRecrod: rec) {
        return SimpleUnzipper(data: data, _bytes: bytes, _cdirs: dirs)
    }
    
    return nil
  }
  
  /// Retrive file names inside the zip
  var files: [String] {
    return _cdirs.keys.array
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
  
}