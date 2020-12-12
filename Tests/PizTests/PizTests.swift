import XCTest
import Piz
import Foundation

final class PizTests: XCTestCase {
  lazy var piz: Piz! = {
    let url = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent("assets/test.epub")
    return Piz(fileURL: url)
  }()
  
  lazy var piz64: Piz! = {
    let url = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent("assets/64.zip")
    return Piz(fileURL: url)
  }()
  
  override func setUp() {
    super.setUp()
    XCTAssertTrue(piz != nil, "Can not create piz")
    XCTAssertTrue(piz64 != nil, "Can not create piz64")
  }
  
  func testNilOrNot()  {
    var fileURL = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent("assets/test.epub")
    var piz = Piz(fileURL: fileURL)
    XCTAssertNotNil(piz)
    fileURL = URL(fileURLWithPath: "dummy path")
    piz = Piz(fileURL: fileURL)
    XCTAssertNil(piz)
  }
  
  func testNumFiles() {
    XCTAssertEqual(piz.files.count, 0x1B, "number of files should be 0x1B")
    XCTAssertEqual(piz64.files.count, 0x1, "number of files should be 0x1")
  }
  
  func testFileExists() {
    XCTAssertTrue(piz.contains(file: "OEBPS/text/book_0006.xhtml"), "OEBPS/text/book_0006.xhtml should be existed")
    XCTAssertTrue(piz64.contains(file: "container.xml"), "container.xml should be existed")
  }
  
  func testDataFetching() {
    if let data = piz["mimetype"] {
      if let str = String(data: data, encoding: .utf8) {
        XCTAssertEqual(str, "application/epub+zip", "data content should be `application/epub+zip`")
      } else {
        XCTFail("can't init string from data")
      }
    } else {
      XCTFail("can not get data")
    }
    
    if let data = piz64["container.xml"] {
      let url = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("assets/container.xml")
      if let str = String(data: data, encoding: .utf8) {
        if let str2 = try? String(contentsOfFile: url.path, encoding: .utf8) {
          XCTAssertEqual(str, str2, "container.xml content should be equal")
        } else {
          XCTFail("Fail to read container.xml on disk")
        }
      } else {
        XCTFail("can't init string from data")
      }
    } else {
      XCTFail("can not get data")
    }
  }
  
  static var allTests = [
    ("testNumFiles", testNumFiles),
    ("testFileExists", testFileExists),
    ("testDataFetching", testDataFetching)
  ]
}
