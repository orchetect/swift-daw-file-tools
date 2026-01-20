//
//  FinalCutPro FCPXML BasicMarkers_1HourProjectStart.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_BasicMarkers_1HourProjectStart: FCPXMLUtilities {
    // MARK: - Tests
    
    @Test
    func parse() async throws {
        // load file
        
        let rawData = try TestResource.FCPXMLExports.basicMarkers_1HourProjectStart.data()
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        
        #expect(fcpxml.version == .ver1_9)
        
        // resources
        
        let resources = fcpxml.root.resources
        #expect(resources.childElements.count == 2)
        
        let r1 = try #require(resources.childElements[safe: 0]?.fcpAsFormat)
        #expect(r1.id == "r1")
        #expect(r1.name == "FFVideoFormat1080p2997")
        #expect(r1.frameDuration == Fraction(1001, 30000))
        #expect(r1.fieldOrder == nil)
        #expect(r1.width == 1920)
        #expect(r1.height == 1080)
        #expect(r1.paspH == nil)
        #expect(r1.paspV == nil)
        #expect(r1.colorSpace == "1-1-1 (Rec. 709)")
        #expect(r1.projection == nil)
        #expect(r1.stereoscopic == nil)
        
        let r2 = try #require(resources.childElements[safe: 1]?.fcpAsEffect)
        #expect(r2.id == "r2")
        #expect(r2.name == "Basic Title")
        #expect(r2.uid == ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti")
        #expect(r2.src == nil)
        
        // library
        
        let library = try #require(fcpxml.root.library)
        
        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
        #expect(library.name == "MyLibrary")
        #expect(library.location == libraryURL)
        #expect(library.events.count == 1)
        
        // events
        
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "Test Event")
        
        // projects
        
        let projects = event.projects.zeroIndexed
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        #expect(project.name == "Test Project")
        #expect(project.startTimecode() == Self.tc("01:00:00:00", .fps29_97))
        
        // sequence
        
        let sequence = project.sequence
        #expect(sequence.format == "r1")
        #expect(sequence.tcStartAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(sequence.tcStartAsTimecode()?.frameRate == .fps29_97)
        #expect(sequence.tcStartAsTimecode()?.subFramesBase == .max80SubFrames)
        #expect(sequence.durationAsTimecode() == Self.tc("00:01:03:29", .fps29_97))
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = sequence.spine
        #expect(spine.storyElements.count == 1)
        
        let storyElements = spine.storyElements.zeroIndexed
        
        let element1 = try #require(storyElements[safe: 0]?.fcpAsTitle)
        #expect(element1.ref == "r2")
        #expect(element1.offsetAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        #expect(element1.offsetAsTimecode()?.frameRate == .fps29_97)
        #expect(element1.name == "Basic Title")
        #expect(element1.startAsTimecode() == Self.tc("00:10:00:00", .fps29_97))
        #expect(element1.startAsTimecode()?.frameRate == .fps29_97)
        #expect(element1.durationAsTimecode() == Self.tc("00:01:03:29", .fps29_97))
        #expect(element1.durationAsTimecode()?.frameRate == .fps29_97)
        
        // markers
        
        let markers = element1.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        #expect(markers.count == 4)
        
        // TODO: finish this - but can't test absolute timecodes without running element extraction
//        let expectedMarker0 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("01:00:29:14", .fps29_97),
//            duration: Self.tc("00:00:00:01", .fps29_97),
//            name: "Standard Marker",
//            metaData: .standard,
//            note: "some notes here"
//        )
//        #expect(markers[safe: 0] == expectedMarker0)
//
//        let expectedMarker1 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("01:00:29:15", .fps29_97),
//            duration: Self.tc("00:00:00:01", .fps29_97),
//            name: "To Do Marker, Incomplete",
//            metaData: .toDo(completed: false),
//            note: "more notes here"
//        )
//        #expect(markers[safe: 1] == expectedMarker1)
//
//        let expectedMarker2 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("01:00:29:16", .fps29_97),
//            duration: Self.tc("00:00:00:01", .fps29_97),
//            name: "To Do Marker, Completed",
//            metaData: .toDo(completed: true),
//            note: "notes yay"
//        )
//        #expect(markers[safe: 2] == expectedMarker2)
//
//        let expectedMarker3 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("01:00:29:17", .fps29_97),
//            duration: Self.tc("00:00:00:01", .fps29_97),
//            name: "Chapter Marker",
//            metaData: .chapter(posterOffset: .init(Self.tc("00:00:00:10.79", .fps29_97))),
//            note: nil
//        )
//        #expect(markers[safe: 3] == expectedMarker3)
    }
}

#endif
