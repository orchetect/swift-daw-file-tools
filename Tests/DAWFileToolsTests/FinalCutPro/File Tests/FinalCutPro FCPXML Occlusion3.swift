//
//  FinalCutPro FCPXML Occlusion3.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_Occlusion3: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.occlusion3.data()
    } }
    
    // MARK: - Tests
    
    @Test
    func parseAndOcclusion() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // resources
        // let resources = fcpxml.resources()
        
        // events
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "Test Event")
        let extractedEvent = await event.element.fcpExtract()
        #expect(extractedEvent.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedEvent.value(forContext: .effectiveOcclusion) == .notOccluded)
        
        // projects
        let projects = event.projects.zeroIndexed
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        let extractedProject = await event.element.fcpExtract()
        #expect(extractedProject.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedProject.value(forContext: .effectiveOcclusion) == .notOccluded)
        
        // sequence
        let sequence = project.sequence
        let extractedSequence = await sequence.element.fcpExtract()
        #expect(extractedSequence.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedSequence.value(forContext: .effectiveOcclusion) == .notOccluded)
        
        // spine
        let spine = sequence.spine
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 3)
        
        // sync-clip 1
        
        let syncClip1 = try #require(storyElements[safe: 2]?.fcpAsSyncClip)
        #expect(syncClip1.name == "1-X-1")
        #expect(syncClip1.lane == nil)
        #expect(syncClip1.offsetAsTimecode() == Self.tc("00:59:58:09", .fps25))
        #expect(syncClip1.offsetAsTimecode()?.frameRate == .fps25)
        #expect(syncClip1.startAsTimecode() == Self.tc("19:54:56:13", .fps25))
        #expect(syncClip1.durationAsTimecode() == Self.tc("00:00:02:07", .fps25))
        #expect(syncClip1.durationAsTimecode()?.frameRate == .fps25)
        let extractedSyncClip1 = await syncClip1.element.fcpExtract()
        #expect(extractedSyncClip1.value(forContext: .absoluteStartAsTimecode()) == Self.tc("00:59:58:09", .fps25))
        #expect(extractedSyncClip1.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedSyncClip1.value(forContext: .effectiveOcclusion) == .notOccluded)
        
        let sc1Markers = syncClip1.storyElements.filter(whereFCPElement: .marker).zeroIndexed
        #expect(sc1Markers.count == 1)
        
        let sc1Marker = try #require(sc1Markers[safe: 0])
        #expect(sc1Marker.name == "Marker 2")
        let extractedSC1Marker = await sc1Marker.element.fcpExtract()
        #expect(extractedSC1Marker.value(forContext: .absoluteStartAsTimecode()) == Self.tc("00:59:58:10", .fps25))
        #expect(extractedSC1Marker.value(forContext: .occlusion) == .notOccluded) // within syncclip1
        #expect(extractedSC1Marker.value(forContext: .effectiveOcclusion) == .notOccluded) // main timeline
        
        // sync-clip 2 (within sync-clip 1, on separate lane)
        
        let syncClip1StoryElements = syncClip1.storyElements.zeroIndexed
        
        let syncClip2 = try #require(syncClip1StoryElements[safe: 3]?.fcpAsSyncClip)
        #expect(syncClip2.name == "1-2-2 MOS")
        #expect(syncClip2.lane == 1)
        #expect(syncClip2.offsetAsTimecode() == Self.tc("19:54:56:13", .fps25))
        #expect(syncClip2.offsetAsTimecode()?.frameRate == .fps25)
        #expect(syncClip2.startAsTimecode() == Self.tc("19:19:01:08", .fps25))
        #expect(syncClip2.durationAsTimecode() == Self.tc("00:00:02:07", .fps25))
        #expect(syncClip2.durationAsTimecode()?.frameRate == .fps25)
        let extractedSyncClip2 = await syncClip2.element.fcpExtract()
        #expect(extractedSyncClip2.value(forContext: .absoluteStartAsTimecode()) == Self.tc("00:59:58:09", .fps25))
        #expect(extractedSyncClip2.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedSyncClip2.value(forContext: .effectiveOcclusion) == .notOccluded)
        
        let sc2Markers = syncClip2.storyElements.filter(whereFCPElement: .marker).zeroIndexed
        #expect(sc2Markers.count == 1)
        
        let sc2Marker = try #require(sc2Markers[safe: 0])
        #expect(sc2Marker.name == "Marker 1")
        let extractedSC2Marker = await sc2Marker.element.fcpExtract()
        #expect(extractedSC2Marker.value(forContext: .absoluteStartAsTimecode()) == Self.tc("00:59:58:09", .fps25))
        #expect(extractedSC2Marker.value(forContext: .occlusion) == .notOccluded) // within syncclip2
        #expect(extractedSC2Marker.value(forContext: .effectiveOcclusion) == .notOccluded) // main timeline
    }
    
    /// Test main timeline markers extraction with limited occlusion conditions.
    @Test
    func extractMarkers_MainTimeline_LimitedOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .mainTimeline)
            .zeroIndexed
        #expect(extractedMarkers.count == 2)
        
        #expect(extractedMarkers.map(\.name) == ["Marker 1", "Marker 2"])
    }
    
    /// Test main timeline markers extraction with all occlusion conditions.
    @Test
    func extractMarkers_MainTimeline_AllOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        var scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
        scope.occlusions = .allCases
        let extractedMarkers = await event
            .extract(preset: .markers, scope: scope)
            .zeroIndexed
        #expect(extractedMarkers.count == 2)
        
        #expect(extractedMarkers.map(\.name) == ["Marker 1", "Marker 2"])
    }
    
    /// Test deep markers extraction with all occlusion conditions.
    @Test
    func extractMarkers_Deep_AllOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        var scope: FinalCutPro.FCPXML.ExtractionScope = .deep()
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        #expect(extractedMarkers.count == 2)
        
        #expect(extractedMarkers.map(\.name) == ["Marker 1", "Marker 2"])
    }
}

#endif
