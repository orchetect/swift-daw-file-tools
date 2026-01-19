//
//  FinalCutPro FCPXML StandaloneAssetClip.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_StandaloneAssetClip: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.standaloneAssetClip.data()
    } }
    
    // MARK: - Tests
    
    @Test
    func parse() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        #expect(fcpxml.version == .ver1_11)
    }
    
    /// Test that FCPXML that doesn't contain a project is still able to extract standalone clips.
    @Test
    func extract() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // timelines
        let timelines = fcpxml.allTimelines()
        #expect(timelines.count == 1)
        
        let anyTimeline = try #require(timelines.first)
        
        // AnyTimeline
        
        let timelineStartTC = try #require(anyTimeline.timelineStartAsTimecode())
        #expect(timelineStartTC.components == .init(h: 00, m: 59, s: 50, f: 00))
        #expect(timelineStartTC.frameRate == .fps29_97)
        let timelineDurTC = try #require(anyTimeline.timelineDurationAsTimecode())
        #expect(timelineDurTC.components == .init(h: 00, m: 00, s: 10, f: 00))
        #expect(timelineDurTC.frameRate == .fps29_97)
        
        // unwrap AssetClip
        
        guard case .assetClip(let assetClip) = anyTimeline else { Issue.record() ; return }
        
        // FCPXMLElementMetaTimeline
        let assetClipStartTC = try #require(anyTimeline.timelineStartAsTimecode())
        #expect(assetClipStartTC.components == .init(h: 00, m: 59, s: 50, f: 00))
        #expect(assetClipStartTC.frameRate == .fps29_97)
        let assetClipDurTC = try #require(anyTimeline.timelineDurationAsTimecode())
        #expect(assetClipDurTC.components == .init(h: 00, m: 00, s: 10, f: 00))
        #expect(assetClipDurTC.frameRate == .fps29_97)
        
        // local XML attributes
        let clipStartTC = try #require(assetClip.startAsTimecode())
        #expect(clipStartTC.components == .init(h: 00, m: 59, s: 50, f: 00))
        #expect(clipStartTC.frameRate == .fps29_97)
        let clipDurTC = try #require(assetClip.durationAsTimecode())
        #expect(clipDurTC.components == .init(h: 00, m: 00, s: 10, f: 00))
        #expect(clipDurTC.frameRate == .fps29_97)
    }
}

#endif
