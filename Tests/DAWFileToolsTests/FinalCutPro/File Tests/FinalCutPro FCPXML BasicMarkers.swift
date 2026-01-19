//
//  FinalCutPro FCPXML BasicMarkers.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_BasicMarkers: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.basicMarkers.data()
    } }
    
    // MARK: - Tests
    
    @Test
    func parse() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        #expect(fcpxml.version == .ver1_9)
        
        // resources (from XML document)
        
        // make sure these aren't nil and they point to the expected elements
        let root = try #require(fcpxml.xml.rootElement()) // `fcpxml` element
        #expect(try root == #require(fcpxml.xml.rootElement()?.fcpRoot))
        #expect(root == fcpxml.root.element)
        
        // resources (from model)
        
        let resources = fcpxml.root.resources
        let xml_resources = try #require(fcpxml.xml.rootElement()?.fcpRootResources)
        // make sure these aren't nil and they point to the expected elements
        #expect(resources == xml_resources)
        
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
        
        let event = try #require(events.zeroIndexed[safe: 0])
        #expect(event.name == "Test Event")
        
        // projects
        
        let projects = event.projects.zeroIndexed
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        #expect(project.name == "Test Project")
        #expect(project.startTimecode() == Self.tc("00:00:00:00", .fps29_97))
        
        // sequence
        
        let sequence = project.sequence
        #expect(sequence.format == "r1")
        #expect(sequence.tcStartAsTimecode() == Self.tc("00:00:00:00", .fps29_97))
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
        #expect(element1.name == "Basic Title")
        #expect(element1.offsetAsTimecode() == Self.tc("00:00:00:00", .fps29_97))
        #expect(element1.offsetAsTimecode()?.frameRate == .fps29_97)
        #expect(element1.startAsTimecode() == Self.tc("00:10:00:00", .fps29_97))
        #expect(element1.startAsTimecode()?.frameRate == .fps29_97)
        #expect(element1.durationAsTimecode() == Self.tc("00:01:03:29", .fps29_97))
        #expect(element1.durationAsTimecode()?.frameRate == .fps29_97)
        
        // markers
        
        let markers = element1.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        #expect(markers.count == 4)
    }
    
    @Test
    func extractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try #require(fcpxml.allProjects().first)
        
        var scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline
        scope.occlusions = .allCases
        
        // clips
        
        let clips = await project
            .extract(types: [.title], scope: .mainTimeline)
        let clip = try #require(clips.first)
        #expect(clip.element.fcpName == "Basic Title")
        // test timecode for both main timeline and local timeline
        #expect(
            clip.value(forContext: .absoluteStartAsTimecode(frameRateSource: .mainTimeline))
                == Self.tc("00:00:00:00", .fps29_97)
        )
        #expect(
            clip.value(forContext: .absoluteStartAsTimecode(frameRateSource: .localToElement))
                == Self.tc("00:10:00:00", .fps29_97)
        )
        #expect(
            clip.value(forContext: .absoluteEndAsTimecode(frameRateSource: .mainTimeline))
                == Self.tc("00:01:03:29", .fps29_97)
        )
        #expect(
            clip.value(forContext: .absoluteEndAsTimecode(frameRateSource: .localToElement))
                == Self.tc("00:11:03:29", .fps29_97)
        )
        
        // markers
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: scope)
            .sortedByAbsoluteStartTimecode()
        // .zeroIndexed // not necessary after sorting - sort returns new array
        
        // note that all these markers are past the end of the clip (occluded)
        #expect(extractedMarkers.count == 4)
        
        let marker0 = try #require(extractedMarkers[safe: 0])
        let marker1 = try #require(extractedMarkers[safe: 1])
        let marker2 = try #require(extractedMarkers[safe: 2])
        let marker3 = try #require(extractedMarkers[safe: 3])
        
        // test timecode for both main timeline and local timeline
        // main timeline start: 00:00:00:00
        // local clip timeline start: 00:10:00:00
        
        #expect(marker0.timecode(frameRateSource: .mainTimeline) == Self.tc("00:50:29:14", .fps29_97))
        #expect(marker0.timecode(frameRateSource: .localToElement) == Self.tc("01:00:29:14", .fps29_97))
        
        #expect(marker1.timecode(frameRateSource: .mainTimeline) == Self.tc("00:50:29:15", .fps29_97))
        #expect(marker1.timecode(frameRateSource: .localToElement) == Self.tc("01:00:29:15", .fps29_97))
        
        #expect(marker2.timecode(frameRateSource: .mainTimeline) == Self.tc("00:50:29:16", .fps29_97))
        #expect(marker2.timecode(frameRateSource: .localToElement) == Self.tc("01:00:29:16", .fps29_97))
        
        #expect(marker3.timecode(frameRateSource: .mainTimeline) == Self.tc("00:50:29:17", .fps29_97))
        #expect(marker3.timecode(frameRateSource: .localToElement) == Self.tc("01:00:29:17", .fps29_97))
    }
}

#endif
