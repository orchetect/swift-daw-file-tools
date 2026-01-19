//
//  FinalCutPro FCPXML Annotations.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_Annotations: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.annotations.data()
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
        #expect(resources.childElements.count == 3)
        
        let r1 = try #require(resources.childElements[safe: 0]?.fcpAsFormat)
        #expect(r1.id == "r1")
        #expect(r1.name == "FFVideoFormat1080p25")
        #expect(r1.frameDuration == Fraction(100,2500))
        #expect(r1.fieldOrder == nil)
        #expect(r1.width == 1920)
        #expect(r1.height == 1080)
        #expect(r1.paspH == nil)
        #expect(r1.paspV == nil)
        #expect(r1.colorSpace == "1-1-1 (Rec. 709)")
        #expect(r1.projection == nil)
        #expect(r1.stereoscopic == nil)
        
        let r2 = try #require(resources.childElements[safe: 1]?.fcpAsAsset)
        #expect(r2.id == "r2")
        #expect(r2.name == "TestVideo")
        #expect(r2.start == .zero)
        #expect(r2.duration == Fraction(738000, 25000))
        #expect(r2.format == "r3")
        #expect(r2.uid == "30C3729DCEE936129873D803DC13B623")
        #expect(r2.hasVideo == true)
        #expect(r2.hasAudio == true)
        #expect(r2.audioSources == 1)
        #expect(r2.audioChannels == 2)
        #expect(r2.audioRate == .rate44_1kHz)
        #expect(r2.videoSources == 1)
        #expect(r2.auxVideoFlags == nil)
        
        let r2MediaRep = r2.mediaRep
        #expect(r2MediaRep.kind == .originalMedia)
        #expect(r2MediaRep.sig == "30C3729DCEE936129873D803DC13B623")
        #expect(r2MediaRep.src == URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/Test%20Event/Original%20Media/TestVideo.m4v")!)
        #expect(r2MediaRep.bookmark == nil)
        
        let r2MetadataXML = try! XMLElement(xmlString: """
            <metadata>
                <md key="com.apple.proapps.studio.rawToLogConversion" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemProfileName" value="SD (6-1-6)"/>
                <md key="com.apple.proapps.studio.cameraISO" value="0"/>
                <md key="com.apple.proapps.studio.cameraColorTemperature" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemCodecs">
                    <array>
                        <string>'avc1'</string>
                        <string>MPEG-4 AAC</string>
                    </array>
                </md>
                <md key="com.apple.proapps.mio.ingestDate" value="2023-01-01 19:46:28 -0800"/>
            </metadata>
            """
        )
        let r2Metadata = FinalCutPro.FCPXML.Metadata(element: r2MetadataXML)
        #expect(r2.metadata == r2Metadata)
        
        let r3 = try #require(resources.childElements[safe: 2]?.fcpAsFormat)
        #expect(r3.id == "r3")
        #expect(r3.name == "FFVideoFormat640x480p25")
        #expect(r3.frameDuration == Fraction(100,2500))
        #expect(r3.fieldOrder == nil)
        #expect(r3.width == 640)
        #expect(r3.height == 480)
        #expect(r3.paspH == nil)
        #expect(r3.paspV == nil)
        #expect(r3.colorSpace == "6-1-6 (Rec. 601 (NTSC))")
        #expect(r3.projection == nil)
        #expect(r3.stereoscopic == nil)
        
        // library
        let library = try #require(fcpxml.root.library)
        
        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
        #expect(library.location == libraryURL)
        
        // events
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "Test Event")
        
        // projects
        let projects = try #require(events[safe: 0]).projects.zeroIndexed
        #expect(projects.count == 1)

        let project = try #require(projects[safe: 0])
        #expect(project.name == "Annotations")
        #expect(project.startTimecode() == Self.tc("01:00:00:00", .fps25))
        
        // sequence
        let sequence = try #require(projects[safe: 0]?.sequence)
        #expect(sequence.format == "r1")
        #expect(sequence.tcStartAsTimecode() == Self.tc("01:00:00:00", .fps25))
        #expect(sequence.tcStartAsTimecode()?.frameRate == .fps25)
        #expect(sequence.tcStartAsTimecode()?.subFramesBase == .max80SubFrames)
        #expect(sequence.durationAsTimecode() == Self.tc("00:00:29:13", .fps25))
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        
        // story elements (clips etc.)
        let spine = sequence.spine
        #expect(spine.storyElements.count == 1)
        
        let storyElements = spine.storyElements.zeroIndexed
        
        let element1 = try #require(storyElements[safe: 0]?.fcpAsAssetClip)
        #expect(element1.ref == "r2")
        #expect(element1.offsetAsTimecode() == Self.tc("01:00:00:00", .fps25))
        #expect(element1.offsetAsTimecode()?.frameRate == .fps25)
        #expect(element1.name == "TestVideo Clip")
        #expect(element1.start == nil)
        #expect(element1.durationAsTimecode() == Self.tc("00:00:29:13", .fps25))
        #expect(element1.durationAsTimecode()?.frameRate == .fps25)
        #expect(element1.audioRole?.rawValue == "dialogue")
        
        #warning("> TODO: finish this - but can't test absolute timecodes without running element extraction")
        // markers
        
        let element1Markers = element1.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        #expect(element1Markers.count == 3)
        
        let expectedE1Marker0 = try #require(element1Markers[safe: 0])
        #expect(expectedE1Marker0.startAsTimecode() == Self.tc("00:00:13:00", .fps25))
        #expect(expectedE1Marker0.durationAsTimecode() == Self.tc("00:00:00:01", .fps25))
        #expect(expectedE1Marker0.name == "Marker 1")
        #expect(expectedE1Marker0.configuration == .standard)
        #expect(expectedE1Marker0.note == nil)
        
        let expectedE1Marker1 = try #require(element1Markers[safe: 1])
        #expect(expectedE1Marker1.startAsTimecode() == Self.tc("00:00:18:00", .fps25))
        #expect(expectedE1Marker1.durationAsTimecode() == Self.tc("00:00:00:01", .fps25))
        #expect(expectedE1Marker1.name == "Marker 2")
        #expect(expectedE1Marker1.configuration == .standard)
        #expect(expectedE1Marker1.note == nil)
        
        let expectedE1Marker2 = try #require(element1Markers[safe: 2])
        #expect(expectedE1Marker2.startAsTimecode() == Self.tc("00:00:27:10", .fps25))
        #expect(expectedE1Marker2.durationAsTimecode() == Self.tc("00:00:00:01", .fps25))
        #expect(expectedE1Marker2.name == "Marker 3")
        #expect(expectedE1Marker2.configuration == .standard)
        #expect(expectedE1Marker2.note == "m3 notes")
        
        // keywords
        
        let element1Keywords = element1.contents
            .filter(whereFCPElement: .keyword)
            .zeroIndexed
        #expect(element1Keywords.count == 2)
        
        // this keyword applies to entire video clip
        let expectedE1Keyword0 = try #require(element1Keywords[safe: 0])
        #expect(expectedE1Keyword0.keywords == ["keyword1"])
        #expect(expectedE1Keyword0.startAsTimecode() == Self.tc("00:00:00:00", .fps25))
        #expect(expectedE1Keyword0.durationAsTimecode() == Self.tc("00:00:29:13", .fps25))
        #expect(expectedE1Keyword0.note == "k1 notes")
        
        let expectedE1Keyword1 = try #require(element1Keywords[safe: 1])
        #expect(expectedE1Keyword1.keywords == ["keyword2"])
        #expect(expectedE1Keyword1.startAsTimecode() == Self.tc("00:00:15:20", .fps25))
        #expect(expectedE1Keyword1.durationAsTimecode() == Self.tc("00:00:08:11", .fps25))
        #expect(expectedE1Keyword1.note == "k2 notes")
        
        // captions
        
        let element1Captions = element1.contents
            .filter(whereFCPElement: .caption)
            .zeroIndexed
        #expect(element1Captions.count == 2)
        
//        let element1Caption0 = try #require(element1Captions[safe: 0])
//        #expect(element1Caption0.note == nil)
//        #expect(element1Caption0.role?.rawValue == "iTT?captionFormat=ITT.en")
//        #expect(Array(element1Caption0.texts) == [
//            FinalCutPro.FCPXML.Text(
//                displayStyle: nil,
//                rollUpHeight: nil,
//                position: nil,
//                placement: .bottom,
//                alignment: nil,
//                textStyles: [
//                    FinalCutPro.FCPXML.Text.TextString(ref: "ts1", string: "caption1 text")
//                ]
//            )
//        ])
//        #expect(element1Caption0.textStyleDefinitions == [
//            try! XMLElement(xmlString: """
//                <text-style-def id="ts1">
//                    <text-style font=".AppleSystemUIFont" fontSize="13" fontFace="Regular" fontColor="1 1 1 1" backgroundColor="0 0 0 1" tabStops="28L 56L 84L 112L 140L 168L 196L 224L 252L 280L 308L 336L"/>
//                </text-style-def>
//                """)
//        ])
//        #expect(element1Caption0.lane == 1)
//        #expect(element1Caption0.offset == Self.tc("00:00:03:00", .fps25))
//        #expect(element1Caption0.name == "caption1")
//        #expect(element1Caption0.start == Self.tc("01:00:00:00", .fps25))
//        #expect(element1Caption0.duration == Self.tc("00:00:04:00", .fps25))
//        #expect(element1Caption0.enabled == false)
//        #expect(element1Caption0.context[.absoluteStart] == Self.tc("01:00:03:00", .fps25))
//        #expect(
//            element1Caption0.context[.localRoles]
//                == [FinalCutPro.FCPXML.CaptionRole(rawValue: "iTT?captionFormat=ITT.en")!.asAnyRole()]
//        )
//        #expect(
//            element1Caption0.context[.inheritedRoles]
//            == [
//                .inherited(.audio(raw: "dialogue")!),
//                .defaulted(.video(raw: "Video")!),
//                .assigned(.caption(raw: "iTT?captionFormat=ITT.en")!)
//            ]
//        )
        
//        let element1Caption1 = try #require(element1Captions[safe: 1])
//        #expect(element1Caption1.note == nil)
//        #expect(element1Caption1.role?.rawValue == "iTT?captionFormat=ITT.en")
//        #expect(element1Caption1.texts == [
//            FinalCutPro.FCPXML.Text(
//                rollUpHeight: nil,
//                position: nil,
//                placement: "bottom",
//                alignment: nil,
//                textStrings: [
//                    FinalCutPro.FCPXML.Text.TextString(ref: "ts2", string: "caption2 text")
//                ]
//            )
//        ])
//        #expect(element1Caption1.textStyleDefinitions == [
//            try! XMLElement(xmlString: """
//                <text-style-def id="ts2">
//                    <text-style font=".AppleSystemUIFont" fontSize="13" fontFace="Regular" fontColor="1 1 1 1" backgroundColor="0 0 0 1" tabStops="28L 56L 84L 112L 140L 168L 196L 224L 252L 280L 308L 336L"/>
//                </text-style-def>
//                """)
//        ])
//        #expect(element1Caption1.lane == 1)
//        #expect(element1Caption1.offset == Self.tc("00:00:09:10", .fps25))
//        #expect(element1Caption1.name == "caption2")
//        #expect(element1Caption1.start == Self.tc("01:00:00:00", .fps25))
//        #expect(element1Caption1.duration == Self.tc("00:00:02:00", .fps25))
//        #expect(element1Caption1.enabled == true)
//        #expect(element1Caption1.context[.absoluteStart] == Self.tc("01:00:09:10", .fps25))
//        #expect(
//            element1Caption1.context[.localRoles]
//                == [FinalCutPro.FCPXML.CaptionRole(rawValue: "iTT?captionFormat=ITT.en")!.asAnyRole()]
//        )
//        #expect(
//            element1Caption1.context[.inheritedRoles]
//            == [
//                .inherited(.audio(raw: "dialogue")!),
//                .defaulted(.video(raw: "Video")!),
//                .assigned(.caption(raw: "iTT?captionFormat=ITT.en")!)
//            ]
//        )
    }
    
    /// Test keywords that apply to each marker.
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
        
        let expectedMarkerCount = 3
        #expect(markers.count == expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // markers
        
        let marker1 = try #require(markers[safe: 0])
        let marker2 = try #require(markers[safe: 1])
        let marker3 = try #require(markers[safe: 2])
        
        // Check keywords while constraining to keyword ranges
        #expect(marker1.keywords(constrainToKeywordRanges: true) == ["keyword1"])
        #expect(marker2.keywords(constrainToKeywordRanges: true) == ["keyword1", "keyword2"])
        #expect(marker3.keywords(constrainToKeywordRanges: true) == ["keyword1"])
        
        // Check keywords while NOT constraining to keyword ranges
        #expect(marker1.keywords(constrainToKeywordRanges: false) == ["keyword1", "keyword2"])
        #expect(marker2.keywords(constrainToKeywordRanges: false) == ["keyword1", "keyword2"])
        #expect(marker3.keywords(constrainToKeywordRanges: false) == ["keyword1", "keyword2"])
    }
}

#endif
