import Foundation

public struct Piz {
  public let data: Data

  public init?(data: Data) {
    guard
      let bytes = data.withUnsafeBytes({ $0.bindMemory(to: UInt8.self).baseAddress })
      else { return nil }
    var recOpt = EndRecord.findEndRecord64(inBytes: bytes, length: data.count)
    if recOpt == nil { recOpt = EndRecord.findEndRecord(inBytes: bytes, length: data.count) }
    guard
      let rec = recOpt,
      let dirs = CDir.findCDirs(inBytes: bytes, length: data.count, record: rec)
      else { return nil }

    self.data = data
    _bytes = bytes
    _cdirs = dirs
  }

  public init?(fileURL: URL) {
    guard let data = try? Data(contentsOf: fileURL) else { return nil }
    self.init(data: data)
  }

  private let _bytes: UnsafePointer<UInt8>
  private let _cdirs: [String: CDir]
}

public extension Piz {
  /// Retrive file names inside the zip
  var files: [String] {
    return Array(_cdirs.keys)
  }

  /// Test if `file` exists
  func contains(file: String) -> Bool {
    return _cdirs[file] != nil
  }

  /// Get data for `file`
  func data(forFile file: String) -> Data? {
    return _cdirs[file].flatMap {
      Uncompressor.uncompressWithCentralDirectory(cdir: $0, fromBytes: _bytes)
    }
  }

  /// Get data for `file`
  subscript(file: String) -> Data? {
    return data(forFile: file)
  }
}
