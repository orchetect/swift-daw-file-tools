//
//  ProTools SessionText ExtendedChars.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_ExtendedChars {
    @Test
    func sessionText_ExtendedChars_TextEditFormat() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.extendedChars_TextEditFormat_PT2023_3.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // (we don't care about header for this test, no need to check it)
        
        // markers
        
        let markers = try #require(sessionInfo.markers)
        #expect(markers.count == 4)
        
        let marker1 = try #require(markers[safe: 0])
        #expect(marker1.name == "Test Ellipsis…")
        #expect(marker1.comment == nil)
        
        let marker2 = try #require(markers[safe: 1])
        #expect(marker2.name == "Test Em Dash —")
        #expect(marker2.comment == nil)
        
        let marker3 = try #require(markers[safe: 2])
        #expect(marker3.name == "Test En Dash –")
        #expect(marker3.comment == nil)
        
        let marker4 = try #require(markers[safe: 3])
        #expect(marker4.name == "Right Side Quote’s Not An Apostrophe")
        #expect(marker4.comment == nil)
    }
    
    @Test
    func sessionText_ExtendedChars_UTF8Format() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.extendedChars_UTF8Format_PT2023_3.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // (we don't care about header for this test, no need to check it)
        
        // markers
        
        let markers = try #require(sessionInfo.markers)
        #expect(markers.count == 4)
        
        let marker1 = try #require(markers[safe: 0])
        #expect(marker1.name == "Test Ellipsis…")
        #expect(marker1.comment == nil)
        
        let marker2 = try #require(markers[safe: 1])
        #expect(marker2.name == "Test Em Dash —")
        #expect(marker2.comment == nil)
        
        let marker3 = try #require(markers[safe: 2])
        #expect(marker3.name == "Test En Dash –")
        #expect(marker3.comment == nil)
        
        let marker4 = try #require(markers[safe: 3])
        #expect(marker4.name == "Right Side Quote’s Not An Apostrophe")
        #expect(marker4.comment == nil)
    }
}
