//
//  ProTools SessionText OrphanData.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
import Testing
import TestingExtensions
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

class ProTools_SessionText_OrphanData: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_OrphanData() throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.unrecognizedSection_23_976fps_DefaultExportOptions_PT2020_3.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        XCTAssertEqual(parseMessages.errors.count, 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // orphan data
        // just test for orphan sections (unrecognized - a hypothetical in case new sections get
        // added to Pro Tools in the future)
        
        XCTAssertEqual(sessionInfo.orphanData?.count, 1)
        
        XCTAssertEqual(
            sessionInfo.orphanData?.first?.heading,
            "U N R E C O G N I Z E D  S E C T I O N"
        )
        XCTAssertEqual(sessionInfo.orphanData?.first?.content, [])
    }
}
