//
//  FinalCutPro FCPXML Occlusion2.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_Occlusion2: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.occlusion2.data()
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
        #expect(storyElements.count == 1)
        
        // story elements
        
        // title1 is 00:00:05:01 long
        
        let title1 = try #require(storyElements[safe: 0]?.fcpAsTitle)
        #expect(title1.ref == "r2")
        #expect(title1.lane == nil)
        #expect(title1.offsetAsTimecode() == Self.tc("00:59:50:00", .fps25))
        #expect(title1.offsetAsTimecode()?.frameRate == .fps25)
        #expect(title1.name == "Basic Title 1")
        #expect(title1.startAsTimecode() == Self.tc("01:00:00:00", .fps25))
        #expect(title1.durationAsTimecode() == Self.tc("00:00:05:01", .fps25))
        #expect(title1.durationAsTimecode()?.frameRate == .fps25)
        
        let extractedTitle1 = await title1.element.fcpExtract()
        #expect(extractedTitle1.value(forContext: .absoluteStartAsTimecode()) == Self.tc("00:59:50:00", .fps25))
        #expect(extractedTitle1.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedTitle1.value(forContext: .effectiveOcclusion) == .notOccluded)
        
        let title1Markers = title1.storyElements.filter(whereFCPElement: .marker).zeroIndexed
        #expect(title1Markers.count == 0)
        
        // title2 is a child of title1, and is 00:05:37:11 long but in a different lane.
        // this allows Final Cut Pro to show the whole 5 min 37 sec 11 frames on the timeline,
        // however it hides markers on title2 that are out of bounds of title1.
        
        let title2 = try #require(title1.storyElements.zeroIndexed[safe: 0]?.fcpAsTitle)
        #expect(title2.ref == "r2")
        #expect(title2.lane == 1)
        #expect(title2.offsetAsTimecode() == Self.tc("01:00:00:00", .fps25))
        #expect(title2.offsetAsTimecode()?.frameRate == .fps25)
        #expect(title2.name == "Basic Title 2")
        #expect(title2.startAsTimecode() == Self.tc("01:00:00:00", .fps25))
        #expect(title2.durationAsTimecode() == Self.tc("00:05:37:11", .fps25))
        #expect(title2.durationAsTimecode()?.frameRate == .fps25)
        
        let extractedTitle2 = await title2.element.fcpExtract()
        #expect(extractedTitle2.value(forContext: .absoluteStartAsTimecode()) == Self.tc("00:59:50:00", .fps25))
        #expect(extractedTitle2.value(forContext: .occlusion) == .partiallyOccluded)
        #expect(extractedTitle2.value(forContext: .effectiveOcclusion) == .partiallyOccluded)
        
        let title2StoryElements = title2.storyElements.zeroIndexed
        #expect(title2StoryElements.count == 2)
        
        let title2Markers = title2StoryElements.filter(whereFCPElement: .marker).zeroIndexed
        #expect(title2Markers.count == 2)
        
        let title2M1 = try #require(title2Markers[safe: 0])
        #expect(title2M1.name == "Visible on Main Timeline")
        
        let extractedTitle2M1 = await title2M1.element.fcpExtract()
        #expect(extractedTitle2M1.value(forContext: .absoluteStartAsTimecode()) == Self.tc("01:00:01:00", .fps25))
        #expect(extractedTitle2M1.value(forContext: .occlusion) == .notOccluded) // within title2
        #expect(extractedTitle2M1.value(forContext: .effectiveOcclusion) == .notOccluded) // main timeline
        
        // this marker is visible on main timeline because even though it's on an interior
        // title, the interior title is on its own lane so it's not occluded by the outer title.
        let title2M2 = try #require(title2Markers[safe: 1])
        #expect(title2M2.name == "Not Visible on Main Timeline")
        
        let extractedTitle2M2 = await title2M2.element.fcpExtract()
        #expect(extractedTitle2M2.value(forContext: .absoluteStartAsTimecode()) == Self.tc("01:01:30:00", .fps25))
        #expect(extractedTitle2M2.value(forContext: .occlusion) == .notOccluded) // within title2
        #expect(extractedTitle2M2.value(forContext: .effectiveOcclusion) == .notOccluded) // main timeline
    }
}

#endif
