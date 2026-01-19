//
//  FinalCutPro FCPXML TwoClipsMarkers.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_TwoClipsMarkers: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.twoClipsMarkers.data()
    } }
    
    // MARK: - Tests
    
    /// Test markers contained on two clips in the same sequence, as well as a marker in a gap
    /// between the clips.
    @Test
    func parse() async throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "Test Event")
        
        // project
        
        let projects = event.projects.zeroIndexed
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        
        // sequence
        
        let sequence = project.sequence
        
        #expect(sequence.format == "r1")
        #expect(sequence.tcStartAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(sequence.tcStartAsTimecode()?.frameRate == .fps29_97)
        #expect(sequence.tcStartAsTimecode()?.subFramesBase == .max80SubFrames)
        #expect(sequence.durationAsTimecode() == Self.tc("00:00:30:00", .fps29_97))
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        
        // spine
        
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 3)
        
        // clips
        
        let title1 = try #require(storyElements[safe: 0]?.fcpAsTitle)
        let gap = try #require(storyElements[safe: 1]?.fcpAsGap)
        let title2 = try #require(storyElements[safe: 2]?.fcpAsTitle)
        
        // clip 1 - title
        
        #expect(title1.ref == "r2")
        #expect(title1.offsetAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(title1.offsetAsTimecode()?.frameRate == .fps29_97)
        #expect(title1.name == "Basic Title 1")
        #expect(title1.startAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(title1.startAsTimecode()?.frameRate == .fps29_97)
        #expect(title1.durationAsTimecode() == Self.tc("00:00:10:00", .fps29_97))
        #expect(title1.durationAsTimecode()?.frameRate == .fps29_97)
        
        // clip 2 - gap
        
        #expect(gap.offsetAsTimecode() == Self.tc("01:00:10:00", .fps29_97))
        #expect(gap.offsetAsTimecode()?.frameRate == .fps29_97)
        #expect(gap.name == "Gap")
        #expect(gap.startAsTimecode() == Self.tc("00:59:56:12", .fps29_97))
        #expect(gap.startAsTimecode()?.frameRate == .fps29_97)
        #expect(gap.durationAsTimecode() == Self.tc("00:00:10:00", .fps29_97))
        #expect(gap.durationAsTimecode()?.frameRate == .fps29_97)
        
        // clip 3 - title
        
        #expect(title2.ref == "r2")
        #expect(title2.offsetAsTimecode() == Self.tc("01:00:20:00", .fps29_97))
        #expect(title2.offsetAsTimecode()?.frameRate == .fps29_97)
        #expect(title2.name == "Basic Title 2")
        #expect(title2.startAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(title2.startAsTimecode()?.frameRate == .fps29_97)
        #expect(title2.durationAsTimecode() == Self.tc("00:00:10:00", .fps29_97))
        #expect(title2.durationAsTimecode()?.frameRate == .fps29_97)
        
        // markers in title 1
        
        let title1Markers = title1.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        // start is 4 seconds 15 frames elapsed in the title's local timeline.
        // the gap's local timeline starts at 01:00:00:00 so the marker's start is 01:00:04:15.
        #expect(title1Markers.count == 1)
        let title1Marker = try #require(title1Markers[safe: 0])
        #expect(title1Marker.startAsTimecode() == Self.tc("01:00:04:15", .fps29_97))
        #expect(title1Marker.durationAsTimecode() == Self.tc("00:00:00:01", .fps29_97))
        #expect(title1Marker.name == "Marker 1")
        #expect(title1Marker.configuration == .standard)
        #expect(title1Marker.note == nil)
        
        // markers in gap
        
        let gapMarkers = gap.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        // start is 5 seconds elapsed in the gap's local timeline.
        // the gap's local timeline starts at 00:59:56:12 so the marker's start is 01:00:01:12.
        // also, it seems that the duration is reduced to 1 audio sample at 48kHz - perhaps
        // in a gap, FCP reduces timing resolution to audio sample rate instead of video frame rate?
        #expect(gapMarkers.count == 1)
        let gapMarker = try #require(gapMarkers[safe: 0])
        #expect(gapMarker.startAsTimecode() == Self.tc("01:00:01:12", .fps29_97))
        #expect(
            try gapMarker.durationAsTimecode()
                == Timecode(.rational(1, 48000), at: .fps29_97, base: .max80SubFrames)
        )
        #expect(gapMarker.name == "Marker 2")
        #expect(gapMarker.configuration == .standard)
        #expect(gapMarker.note == nil)
        
        // markers in title 2
        
        let title2Markers = title2.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        // start is 7 seconds elapsed in the title's local timeline.
        // the gap's local timeline starts at 01:00:00:00 so the marker's start is 01:00:07:00.
        #expect(title2Markers.count == 1)
        let title2Marker = try #require(title2Markers[safe: 0])
        #expect(title2Marker.startAsTimecode() == Self.tc("01:00:07:00", .fps29_97))
        #expect(title2Marker.durationAsTimecode() == Self.tc("00:00:00:01", .fps29_97))
        #expect(title2Marker.name == "Marker 3")
        #expect(title2Marker.configuration == .standard)
        #expect(title2Marker.note == nil)
        
        // test single-element extraction
        let title2MarkerExtracted = await title2Marker.element.fcpExtract()
        #expect(
            title2MarkerExtracted.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:00:27:00", .fps29_97)
        )
    }
    
    @Test
    func extractMarkers() async throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .init())
            .zeroIndexed
        #expect(extractedMarkers.count == 3)
        
        let extractedTitle1Marker = try #require(extractedMarkers[safe: 0])
        #expect(extractedTitle1Marker.name == "Marker 1") // basic identity check
        #expect(extractedTitle1Marker.value(forContext: .ancestorEventName) == "Test Event")
        #expect(extractedTitle1Marker.value(forContext: .ancestorProjectName) == "TwoClipsMarkers")
        #expect(
            extractedTitle1Marker.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:00:04:15", .fps29_97)
        )
        #expect(extractedTitle1Marker.value(forContext: .parentType) == .title)
        #expect(extractedTitle1Marker.value(forContext: .parentName) == "Basic Title 1")
        #expect(
            extractedTitle1Marker.value(forContext: .parentAbsoluteStartAsTimecode())
                == Self.tc("01:00:00:00", .fps29_97)
        )
        #expect(
            extractedTitle1Marker.value(forContext: .parentDurationAsTimecode())
                == Self.tc("00:00:10:00", .fps29_97)
        )
        
        let extractedGapMarker = try #require(extractedMarkers[safe: 1])
        #expect(extractedGapMarker.name == "Marker 2") // basic identity check
        #expect(extractedGapMarker.value(forContext: .ancestorEventName) == "Test Event")
        #expect(extractedGapMarker.value(forContext: .ancestorProjectName) == "TwoClipsMarkers")
        #expect(
            extractedGapMarker.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:00:15:00", .fps29_97)
        )
        #expect(extractedGapMarker.value(forContext: .parentType) == .gap)
        #expect(extractedGapMarker.value(forContext: .parentName) == "Gap")
        #expect(
            extractedGapMarker.value(forContext: .parentAbsoluteStartAsTimecode())
                == Self.tc("01:00:10:00", .fps29_97)
        )
        #expect(
            extractedGapMarker.value(forContext: .parentDurationAsTimecode())
                == Self.tc("00:00:10:00", .fps29_97)
        )
        
        let extractedTitle2Marker = try #require(extractedMarkers[safe: 2])
        #expect(extractedTitle2Marker.name == "Marker 3")
        #expect(extractedTitle2Marker.value(forContext: .ancestorEventName) == "Test Event")
        #expect(extractedTitle2Marker.value(forContext: .ancestorProjectName) == "TwoClipsMarkers")
        #expect(
            extractedTitle2Marker.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:00:27:00", .fps29_97)
        )
        #expect(extractedTitle2Marker.value(forContext: .parentType) == .title)
        #expect(extractedTitle2Marker.value(forContext: .parentName) == "Basic Title 2")
        #expect(
            extractedTitle2Marker.value(forContext: .parentAbsoluteStartAsTimecode())
                == Self.tc("01:00:20:00", .fps29_97)
        )
        #expect(
            extractedTitle2Marker.value(forContext: .parentDurationAsTimecode())
                == Self.tc("00:00:10:00", .fps29_97)
        )
    }
    
    @Test
    func extractMarkers_ExcludeTitle() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            excludedTraversalTypes: [.title]
        )
        let extractedMarkers = await event
            .extract(preset: .markers, scope: scope)
            .zeroIndexed
        #expect(extractedMarkers.count == 1)
        
        let extractedGapMarker = try #require(extractedMarkers[safe: 0])
        #expect(extractedGapMarker.name == "Marker 2")
    }
    
    @Test
    func extractMarkers_ExcludeGap() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            excludedTraversalTypes: [.gap]
        )
        let extractedMarkers = await event
            .extract(preset: .markers, scope: scope)
            .zeroIndexed
        #expect(extractedMarkers.count == 2)
        
        let extractedTitle1Marker = try #require(extractedMarkers[safe: 0])
        #expect(extractedTitle1Marker.name == "Marker 1")
        
        let extractedTitle2Marker = try #require(extractedMarkers[safe: 1])
        #expect(extractedTitle2Marker.name == "Marker 3")
    }
    
    @Test
    func extractMarkers_ExcludeGapAndTitle() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            excludedTraversalTypes: [.gap, .title]
        )
        let extractedMarkers = await event
            .extract(preset: .markers, scope: scope)
            .zeroIndexed
        #expect(extractedMarkers.count == 0)
    }
}

#endif
