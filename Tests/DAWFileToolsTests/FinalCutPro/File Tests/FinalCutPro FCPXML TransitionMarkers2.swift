//
//  FinalCutPro FCPXML TransitionMarkers2.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_TransitionMarkers2: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.transitionMarkers2.data()
    } }
    
    /// Project @ 24fps.
    let projectFrameRate: TimecodeFrameRate = .fps24
    
    // MARK: - Tests
    
    @Test
    func parse() async throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        #expect(fcpxml.version == .ver1_13)
        
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
        
        // spine
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 4)
        
        // story elements
        
        let transitionClip1 = try #require(storyElements[safe: 0]?.fcpAsTransition)
        #expect(transitionClip1.name == "Cross Dissolve")
        #expect(transitionClip1.offsetAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(transitionClip1.offsetAsTimecode()?.frameRate == projectFrameRate)
        #expect(transitionClip1.timelineStartAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(transitionClip1.durationAsTimecode() == Self.tc("00:00:02:00", projectFrameRate))
        #expect(transitionClip1.durationAsTimecode()?.frameRate == projectFrameRate)
        
        let titleClip1 = try #require(storyElements[safe: 1]?.fcpAsTitle)
        
        let transitionClip2 = try #require(storyElements[safe: 2]?.fcpAsTransition)
        #expect(transitionClip2.name == "Band")
        #expect(transitionClip2.offsetAsTimecode() == Self.tc("01:00:09:13", projectFrameRate))
        #expect(transitionClip2.offsetAsTimecode()?.frameRate == projectFrameRate)
        #expect(transitionClip2.durationAsTimecode() == Self.tc("00:00:01:00", projectFrameRate))
        #expect(transitionClip2.durationAsTimecode()?.frameRate == projectFrameRate)
        
        let titleClip2 = try #require(storyElements[safe: 3]?.fcpAsTitle)
        
        // transition clip 1 markers
        
        let trs1StoryElements = transitionClip1.storyElements
        let trs1Marker1 = try #require(trs1StoryElements[1].fcpAsMarker)
        #expect(trs1Marker1.name == "Marker 1")
        #expect(trs1Marker1.start == Fraction(3600, 1))
        #expect(trs1Marker1.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        #expect(trs1Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        let trs1Marker2 = try #require(trs1StoryElements[2].fcpAsMarker)
        #expect(trs1Marker2.name == "Marker 2")
        #expect(trs1Marker2.startAsTimecode() == Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        let trs1Marker3 = try #require(trs1StoryElements[3].fcpAsMarker)
        #expect(trs1Marker3.name == "Marker 3")
        #expect(trs1Marker3.startAsTimecode() == Self.tc("01:00:01:23", projectFrameRate)) // start attr, not absolute
        
        let clip1StoryElements = titleClip1.storyElements
        let clip1Marker1 = try #require(clip1StoryElements[2].fcpAsMarker)
        #expect(clip1Marker1.name == "Marker 4")
        #expect(clip1Marker1.startAsTimecode() == Self.tc("01:00:02:00", projectFrameRate)) // start attr, happens to be absolute
        #expect(clip1Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        let clip1Marker2 = try #require(clip1StoryElements[3].fcpAsMarker)
        #expect(clip1Marker2.name == "Marker 5")
        #expect(clip1Marker2.startAsTimecode() == Self.tc("01:00:02:01", projectFrameRate)) // start attr, happens to be absolute
        let clip1Marker3 = try #require(clip1StoryElements[4].fcpAsMarker)
        #expect(clip1Marker3.name == "Marker 6")
        #expect(clip1Marker3.startAsTimecode() == Self.tc("01:00:09:12", projectFrameRate)) // start attr, happens to be absolute
        
        let trs2StoryElements = transitionClip2.storyElements
        let trs2Marker1 = try #require(trs2StoryElements[1].fcpAsMarker)
        #expect(trs2Marker1.name == "Marker 7")
        #expect(trs2Marker1.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        #expect(trs2Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        let trs2Marker2 = try #require(trs2StoryElements[2].fcpAsMarker)
        #expect(trs2Marker2.name == "Marker 8")
        #expect(trs2Marker2.startAsTimecode() == Self.tc("01:00:00:01", projectFrameRate)) // start attr, not absolute
        
        let clip2StoryElements = titleClip2.storyElements
        let clip2Marker1 = try #require(clip2StoryElements[3].fcpAsMarker)
        #expect(clip2Marker1.name == "Marker 9")
        #expect(clip2Marker1.startAsTimecode() == Self.tc("01:00:00:12", projectFrameRate)) // start attr, with 1-frame clip offset
        #expect(clip2Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        let clip2Marker2 = try #require(clip2StoryElements[4].fcpAsMarker)
        #expect(clip2Marker2.name == "Marker 10")
        #expect(clip2Marker2.startAsTimecode() == Self.tc("01:00:00:13", projectFrameRate)) // start attr, with 1-frame clip offset
    }
    
    @Test
    func extractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try #require(fcpxml.allProjects().first)
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: .mainTimeline)
            .sortedByAbsoluteStartTimecode()
            // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 10
        #expect(markers.count == expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        let marker1 = try #require(markers[safe: 0])
        #expect(marker1.name == "Marker 1")
        #expect(marker1.timecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(marker1.timecode()?.frameRate == projectFrameRate)
        
        let marker2 = try #require(markers[safe: 1])
        #expect(marker2.name == "Marker 2")
        #expect(marker2.timecode() == Self.tc("01:00:00:12", projectFrameRate))
        
        let marker3 = try #require(markers[safe: 2])
        #expect(marker3.name == "Marker 3")
        #expect(marker3.timecode() == Self.tc("01:00:01:23", projectFrameRate))
        
        let marker4 = try #require(markers[safe: 3])
        #expect(marker4.name == "Marker 4")
        #expect(marker4.timecode() == Self.tc("01:00:02:00", projectFrameRate))
        
        let marker5 = try #require(markers[safe: 4])
        #expect(marker5.name == "Marker 5")
        #expect(marker5.timecode() == Self.tc("01:00:02:01", projectFrameRate))
        
        let marker6 = try #require(markers[safe: 5])
        #expect(marker6.name == "Marker 6")
        #expect(marker6.timecode() == Self.tc("01:00:09:12", projectFrameRate))
        
        let marker7 = try #require(markers[safe: 6])
        #expect(marker7.name == "Marker 7")
        #expect(marker7.timecode() == Self.tc("01:00:09:13", projectFrameRate))
        
        let marker8 = try #require(markers[safe: 7])
        #expect(marker8.name == "Marker 8")
        #expect(marker8.timecode() == Self.tc("01:00:09:14", projectFrameRate))
        
        let marker9 = try #require(markers[safe: 8])
        #expect(marker9.name == "Marker 9")
        #expect(marker9.timecode() == Self.tc("01:00:10:13", projectFrameRate))
        
        let marker10 = try #require(markers[safe: 9])
        #expect(marker10.name == "Marker 10")
        #expect(marker10.timecode() == Self.tc("01:00:10:14", projectFrameRate))
    }
}

#endif
