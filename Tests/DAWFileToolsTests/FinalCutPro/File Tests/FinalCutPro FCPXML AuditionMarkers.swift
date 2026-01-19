//
//  FinalCutPro FCPXML AuditionMarkers.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_AuditionMarkers: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.auditionMarkers.data()
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
        
        // resources
        let resources = fcpxml.root.resources
        #expect(resources.childElements.count == 2)
        
        // events
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        
        // project
        let projects = event.projects.zeroIndexed
        #expect(projects.count == 1)
        
        // let project = try #require(projects[safe: 0])
        
        // sequence
        let sequence = try #require(projects[safe: 0]?.sequence)
        
        // story elements (clips etc.)
        
        let spine = sequence.spine
        #expect(spine.storyElements.count == 1)
        
        let storyElements = spine.storyElements.zeroIndexed
        
        let audition = try #require(storyElements[safe: 0]?.fcpAsAudition)
        #expect(audition.offsetAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(audition.offsetAsTimecode()?.frameRate == .fps29_97)
        #expect(audition.clips.count == 2)
        
        // "active" audition
        let audition1 = try #require(audition.clips[safe: 0]?.fcpAsTitle)
        #expect(audition1.ref == "r2")
        #expect(audition1.name == "Basic Title 1")
        #expect(audition1.startAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(audition1.startAsTimecode()?.frameRate == .fps29_97)
        #expect(audition1.durationAsTimecode() == Self.tc("00:00:10:00", .fps29_97))
        #expect(audition1.durationAsTimecode()?.frameRate == .fps29_97)
        
        // first "inactive" audition
        let audition2 = try #require(audition.clips[safe: 1]?.fcpAsTitle)
        #expect(audition2.ref == "r2")
        #expect(audition2.name == "Basic Title 2")
        #expect(audition2.startAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(audition2.startAsTimecode()?.frameRate == .fps29_97)
        #expect(audition2.durationAsTimecode() == Self.tc("00:00:10:00", .fps29_97))
        #expect(audition2.durationAsTimecode()?.frameRate == .fps29_97)
        
        // markers
        
        let audition1Markers = audition1.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        #expect(audition1Markers.count == 1)
        
        let a1Marker = try #require(audition1Markers[safe: 0])
        #expect(a1Marker.startAsTimecode() == Self.tc("01:00:05:00", .fps29_97))
        #expect(a1Marker.durationAsTimecode() == Self.tc("00:00:00:01", .fps29_97))
        #expect(a1Marker.name == "Marker 1")
        #expect(a1Marker.configuration == .standard)
        #expect(a1Marker.note == nil)
        #warning("> TODO: finish this - but can't test absolute timecodes without running element extraction")
        // #expect(a1Marker.context[.absoluteStart] == Self.tc("01:00:05:00", .fps29_97))
        // #expect(a1Marker.context[.parentType] == .story(.anyClip(.title)))
        // #expect(a1Marker.context[.parentName] == "Basic Title 1")
        // #expect(a1Marker.context[.parentAbsoluteStart] == Self.tc("01:00:00:00", .fps29_97))
        // #expect(a1Marker.context[.parentDuration] == Self.tc("00:00:10:00", .fps29_97))
        // #expect(a1Marker.context[.ancestorEventName] == "Test Event")
        // #expect(a1Marker.context[.ancestorProjectName] == "AuditionMarkers")
        
        let audition2Markers = audition2.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        #expect(audition2Markers.count == 1)
        
        let a2Marker = try #require(audition2Markers[safe: 0])
        #expect(a2Marker.startAsTimecode() == Self.tc("01:00:02:00", .fps29_97))
        #expect(a2Marker.durationAsTimecode() == Self.tc("00:00:00:01", .fps29_97))
        #expect(a2Marker.name == "Marker 2")
        #expect(a2Marker.configuration == .standard)
        #expect(a2Marker.note == nil)
        #warning("> TODO: finish this - but can't test absolute timecodes without running element extraction")
        // #expect(a2Marker.context[.absoluteStart] == Self.tc("01:00:02:00", .fps29_97))
        // #expect(a2Marker.context[.parentType] == .story(.anyClip(.title)))
        // #expect(a2Marker.context[.parentName] == "Basic Title 2")
        // #expect(a2Marker.context[.parentAbsoluteStart] == Self.tc("01:00:00:00", .fps29_97))
        // #expect(a2Marker.context[.parentDuration] == Self.tc("00:00:10:00", .fps29_97))
        // #expect(a2Marker.context[.ancestorEventName] == "Test Event")
        // #expect(a2Marker.context[.ancestorProjectName] == "AuditionMarkers")
    }
    
    #warning("> TODO: uncomment and fix unit tests")
    
    @Test
    func extractMarkers_activeAudition() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            auditions: .active
        )
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        #expect(extractedMarkers.count == 1)
        
        let marker = try #require(extractedMarkers.zeroIndexed[safe: 0])
        #expect(marker.name == "Marker 1")
    }
    
    @Test
    func extractMarkers_allAuditions() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            auditions: .all
        )
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        #expect(extractedMarkers.count == 2)
        
        let marker1 = try #require(extractedMarkers.zeroIndexed[safe: 0])
        #expect(marker1.name == "Marker 1")
        
        let marker2 = try #require(extractedMarkers.zeroIndexed[safe: 1])
        #expect(marker2.name == "Marker 2")
    }
}

#endif
