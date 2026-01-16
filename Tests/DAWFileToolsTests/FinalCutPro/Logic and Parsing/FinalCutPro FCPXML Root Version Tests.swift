//
//  FinalCutPro FCPXML Root Version Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

final class FinalCutPro_FCPXML_RootVersionTests: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    typealias Version = FinalCutPro.FCPXML.Version
    
    func testVersion_1_12() {
        let v = Version(1, 12)
        
        XCTAssertEqual(v.major, 1)
        XCTAssertEqual(v.minor, 12)
        XCTAssertEqual(v.patch, 0)
        XCTAssertEqual(v.semanticVersion.build, nil)
        XCTAssertEqual(v.semanticVersion.preRelease, nil)
        
        XCTAssertEqual(v.rawValue, "1.12")
    }
    
    func testVersion_1_12_1() {
        let v = Version(1, 12, 1)
        
        XCTAssertEqual(v.major, 1)
        XCTAssertEqual(v.minor, 12)
        XCTAssertEqual(v.patch, 1)
        XCTAssertEqual(v.semanticVersion.build, nil)
        XCTAssertEqual(v.semanticVersion.preRelease, nil)
        
        XCTAssertEqual(v.rawValue, "1.12.1")
    }
    
    func testVersion_Equatable() {
        XCTAssertEqual(
            Version(1, 12),
            Version(1, 12)
        )
        
        XCTAssertNotEqual(
            Version(1, 12),
            Version(1, 13)
        )
        
        XCTAssertNotEqual(
            Version(1, 12),
            Version(2, 12)
        )
    }
    
    func testVersion_Comparable() {
        XCTAssertFalse(
            Version(1, 12) < Version(1, 12)
        )
        
        XCTAssertFalse(
            Version(1, 12) > Version(1, 12)
        )
        
        XCTAssertTrue(
            Version(1, 11) < Version(1, 12)
        )
        
        XCTAssertTrue(
            Version(1, 12) > Version(1, 11)
        )
        
        XCTAssertTrue(
            Version(1, 10) < Version(2, 3)
        )
        
        XCTAssertTrue(
            Version(2, 3) > Version(1, 10)
        )
    }
    
    func testVersion_RawValue_EdgeCase_MajorVersionOnly() throws {
        let v = try XCTUnwrap(Version(rawValue: "2"))
        
        XCTAssertEqual(v.major, 2)
        XCTAssertEqual(v.minor, 0)
        XCTAssertEqual(v.patch, 0)
        XCTAssertEqual(v.semanticVersion.build, nil)
        XCTAssertEqual(v.semanticVersion.preRelease, nil)
        
        XCTAssertEqual(v.rawValue, "2.0")
    }
    
    func testVersion_RawValue_Invalid() throws {
        XCTAssertNil(Version(rawValue: ""))
        XCTAssertNil(Version(rawValue: "1."))
        XCTAssertNil(Version(rawValue: "1.A"))
        XCTAssertNil(Version(rawValue: "A"))
        XCTAssertNil(Version(rawValue: "A.1"))
        XCTAssertNil(Version(rawValue: "A.A"))
        XCTAssertNil(Version(rawValue: "A.A.A"))
        XCTAssertNil(Version(rawValue: "1.12."))
        XCTAssertNil(Version(rawValue: "1.12.A"))
    }
    
    func testVersion_Init_RawValue() throws {
        let v = try XCTUnwrap(Version(rawValue: "1.12"))
        
        XCTAssertEqual(v.major, 1)
        XCTAssertEqual(v.minor, 12)
    }
    
    func testVersion_RawValue() throws {
        let v = try XCTUnwrap(Version(rawValue: "1.12"))
        
        XCTAssertEqual(v.rawValue, "1.12")
    }
}

#endif
