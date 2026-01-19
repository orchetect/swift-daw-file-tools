//
//  FinalCutPro FCPXML StandaloneLibraryEventClip.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_StandaloneLibraryEventClip: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.standaloneLibraryEventClip.data()
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
        #expect(timelineStartTC.components == .init(h: 00, m: 00, s: 00, f: 00))
        #expect(timelineStartTC.frameRate == .fps25)
        let timelineDurTC = try #require(anyTimeline.timelineDurationAsTimecode())
        #expect(timelineDurTC.components == .init(h: 00, m: 01, s: 31, f: 12))
        #expect(timelineDurTC.frameRate == .fps25)
        
        // unwrap RefClip
        
        guard case .refClip(let refClip) = anyTimeline else { Issue.record() ; return }
        
        // FCPXMLElementMetaTimeline
        let refClipStartTC = try #require(refClip.timelineStartAsTimecode())
        #expect(refClipStartTC.components == .init(h: 00, m: 00, s: 00, f: 00))
        #expect(refClipStartTC.frameRate == .fps25)
        let refClipDurTC = try #require(refClip.timelineDurationAsTimecode())
        #expect(refClipDurTC.components == .init(h: 00, m: 01, s: 31, f: 12))
        #expect(refClipDurTC.frameRate == .fps25)
        
        // local XML attributes
        // `ref-clip` itself doesn't have a start time, but its resource does
        #expect(refClip.startAsTimecode() == nil)
        // `ref-clip` itself doesn't have a duration time, but its resource does
        #expect(refClip.durationAsTimecode() == nil)
        
        // test markers
        
        let markers = await refClip.extract(preset: .markers, scope: .mainTimeline)
        #expect(markers.count == 10)
    }
}

#endif
