//
//  FinalCutPro FCPXML TransitionMarkers1.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_TransitionMarkers1: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.transitionMarkers1.data()
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
        #expect(storyElements.count == 7)
        
        // story elements
        
        // (start of timeline)
        let transitionClip1 = try #require(storyElements[safe: 0]?.fcpAsTransition)
        #expect(transitionClip1.name == "Cross Dissolve")
        #expect(transitionClip1.offsetAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(transitionClip1.offsetAsTimecode()?.frameRate == projectFrameRate)
        #expect(transitionClip1.timelineStartAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(transitionClip1.durationAsTimecode() == Self.tc("00:00:01:00", projectFrameRate))
        #expect(transitionClip1.durationAsTimecode()?.frameRate == projectFrameRate)
        
        let titleClip1 = try #require(storyElements[safe: 1]?.fcpAsTitle)
        #expect(titleClip1.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(titleClip1.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(titleClip1.offsetAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(titleClip1.offsetAsTimecode()?.frameRate == projectFrameRate)
        
        let transitionClip2 = try #require(storyElements[safe: 2]?.fcpAsTransition)
        #expect(transitionClip2.name == "Cross Dissolve")
        #expect(transitionClip2.offsetAsTimecode() == Self.tc("01:00:09:12", projectFrameRate))
        #expect(transitionClip2.offsetAsTimecode()?.frameRate == projectFrameRate)
        #expect(transitionClip2.durationAsTimecode() == Self.tc("00:00:01:00", projectFrameRate))
        #expect(transitionClip2.durationAsTimecode()?.frameRate == projectFrameRate)
        
        let titleClip2 = try #require(storyElements[safe: 3]?.fcpAsTitle)
        #expect(titleClip2.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(titleClip2.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(titleClip2.offsetAsTimecode() == Self.tc("01:00:10:00", projectFrameRate))
        #expect(titleClip2.offsetAsTimecode()?.frameRate == projectFrameRate)
        
        let transitionClip3 = try #require(storyElements[safe: 4]?.fcpAsTransition)
        #expect(transitionClip3.name == "Cross Dissolve")
        #expect(transitionClip3.offsetAsTimecode() == Self.tc("01:00:19:12", projectFrameRate))
        #expect(transitionClip3.offsetAsTimecode()?.frameRate == projectFrameRate)
        #expect(transitionClip3.durationAsTimecode() == Self.tc("00:00:01:00", projectFrameRate))
        #expect(transitionClip3.durationAsTimecode()?.frameRate == projectFrameRate)
        
        let titleClip3 = try #require(storyElements[safe: 5]?.fcpAsTitle)
        #expect(titleClip3.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(titleClip3.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(titleClip3.offsetAsTimecode() == Self.tc("01:00:20:00", projectFrameRate))
        #expect(titleClip3.offsetAsTimecode()?.frameRate == projectFrameRate)
        
        // (end of timeline)
        let transitionClip4 = try #require(storyElements[safe: 6]?.fcpAsTransition)
        #expect(transitionClip4.name == "Cross Dissolve")
        #expect(transitionClip4.offsetAsTimecode() == Self.tc("01:00:29:00", projectFrameRate))
        #expect(transitionClip4.offsetAsTimecode()?.frameRate == projectFrameRate)
        #expect(transitionClip4.durationAsTimecode() == Self.tc("00:00:01:00", projectFrameRate))
        #expect(transitionClip4.durationAsTimecode()?.frameRate == projectFrameRate)
        
        // transition clip 1 markers
        
        let trs1StoryElements = transitionClip1.storyElements
        let trs1Marker1 = try #require(trs1StoryElements[1].fcpAsMarker)
        #expect(trs1Marker1.name == "Marker 1")
        #expect(trs1Marker1.start == Fraction(3600, 1))
        #expect(trs1Marker1.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        #expect(trs1Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(trs1Marker1.element._fcpCalculateAbsoluteStart() == 3600.0)
        let trs1Marker2 = try #require(trs1StoryElements[2].fcpAsMarker)
        #expect(trs1Marker2.name == "Marker 2")
        #expect(trs1Marker2.startAsTimecode() == Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        #expect(trs1Marker2.element._fcpCalculateAbsoluteStart() == 3600.5)
        
        let clip1StoryElements = titleClip1.storyElements
        let clip1Marker1 = try #require(clip1StoryElements[2].fcpAsMarker)
        #expect(clip1Marker1.name == "Marker 3")
        #expect(clip1Marker1.startAsTimecode() == Self.tc("01:00:01:00", projectFrameRate)) // start attr, not absolute
        #expect(clip1Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(clip1Marker1.element._fcpCalculateAbsoluteStart() == 3601.0)
        
        let trs2StoryElements = transitionClip2.storyElements
        let trs2Marker1 = try #require(trs2StoryElements[1].fcpAsMarker)
        #expect(trs2Marker1.name == "Marker 4")
        #expect(trs2Marker1.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        #expect(trs2Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(trs2Marker1.element._fcpCalculateAbsoluteStart() == 3609.5)
        let trs2Marker2 = try #require(trs2StoryElements[2].fcpAsMarker)
        #expect(trs2Marker2.name == "Marker 5")
        #expect(trs2Marker2.startAsTimecode() == Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        #expect(trs2Marker2.element._fcpCalculateAbsoluteStart() == 3610.0)
        
        let clip2StoryElements = titleClip2.storyElements
        let clip2Marker1 = try #require(clip2StoryElements[2].fcpAsMarker)
        #expect(clip2Marker1.name == "Marker 6")
        #expect(clip2Marker1.startAsTimecode() == Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        #expect(clip2Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(clip2Marker1.element._fcpCalculateAbsoluteStart() == 3610.5)
        
        let trs3StoryElements = transitionClip3.storyElements
        let trs3Marker1 = try #require(trs3StoryElements[1].fcpAsMarker)
        #expect(trs3Marker1.name == "Marker 7")
        #expect(trs3Marker1.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        #expect(trs3Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(trs3Marker1.element._fcpCalculateAbsoluteStart() == 3619.5)
        let trs3Marker2 = try #require(trs3StoryElements[2].fcpAsMarker)
        #expect(trs3Marker2.name == "Marker 8")
        #expect(trs3Marker2.startAsTimecode() == Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        #expect(trs3Marker2.element._fcpCalculateAbsoluteStart() == 3620.0)
        
        let clip3StoryElements = titleClip3.storyElements
        let clip3Marker1 = try #require(clip3StoryElements[2].fcpAsMarker)
        #expect(clip3Marker1.name == "Marker 9")
        #expect(clip3Marker1.startAsTimecode() == Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        #expect(clip3Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(clip3Marker1.element._fcpCalculateAbsoluteStart() == 3620.5)
        
        let trs4StoryElements = transitionClip4.storyElements
        let trs4Marker1 = try #require(trs4StoryElements[1].fcpAsMarker)
        #expect(trs4Marker1.name == "Marker 10")
        #expect(trs4Marker1.startAsTimecode() == Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        #expect(trs4Marker1.startAsTimecode()?.frameRate == projectFrameRate)
        #expect(trs4Marker1.element._fcpCalculateAbsoluteStart() == 3629.0)
        let trs4Marker2 = try #require(trs4StoryElements[2].fcpAsMarker)
        #expect(trs4Marker2.name == "Marker 11")
        #expect(trs4Marker2.startAsTimecode() == Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        #expect(trs4Marker2.element._fcpCalculateAbsoluteStart() == 3629.5)
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
        
        let expectedMarkerCount = 11
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
        #expect(marker3.timecode() == Self.tc("01:00:01:00", projectFrameRate))
        
        let marker4 = try #require(markers[safe: 3])
        #expect(marker4.name == "Marker 4")
        #expect(marker4.timecode() == Self.tc("01:00:09:12", projectFrameRate))
        
        let marker5 = try #require(markers[safe: 4])
        #expect(marker5.name == "Marker 5")
        #expect(marker5.timecode() == Self.tc("01:00:10:00", projectFrameRate))
        
        let marker6 = try #require(markers[safe: 5])
        #expect(marker6.name == "Marker 6")
        #expect(marker6.timecode() == Self.tc("01:00:10:12", projectFrameRate))
        
        let marker7 = try #require(markers[safe: 6])
        #expect(marker7.name == "Marker 7")
        #expect(marker7.timecode() == Self.tc("01:00:19:12", projectFrameRate))
        
        let marker8 = try #require(markers[safe: 7])
        #expect(marker8.name == "Marker 8")
        #expect(marker8.timecode() == Self.tc("01:00:20:00", projectFrameRate))
        
        let marker9 = try #require(markers[safe: 8])
        #expect(marker9.name == "Marker 9")
        #expect(marker9.timecode() == Self.tc("01:00:20:12", projectFrameRate))
        
        let marker10 = try #require(markers[safe: 9])
        #expect(marker10.name == "Marker 10")
        #expect(marker10.timecode() == Self.tc("01:00:29:00", projectFrameRate))
        
        let marker11 = try #require(markers[safe: 10])
        #expect(marker11.name == "Marker 11")
        #expect(marker11.timecode() == Self.tc("01:00:29:12", projectFrameRate))
    }
}

#endif
