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
  
  public let data: Data

  public init?(data: Data) {
    let bytes = unsafeBitCast((data as NSData).bytes, to: UnsafePointer<UInt8>.self)
    let len = data.count
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

  public init?(fileURL: URL) {
    guard let data = try? Data(contentsOf: fileURL) else { return nil }
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
  func containsFile(_ file: String) -> Bool {
    return _cdirs[file] != nil
  }
  
  /// Get data for `file`
  func dataForFile(_ file: String) -> Data? {
    if let cdir = _cdirs[file] {
      return Uncompressor.uncompressWithCentralDirectory(cdir, fromBytes: _bytes)
    }
    
    return nil
  }

  subscript(file: String) -> Data? {
    return dataForFile(file)
  }

}
