//
//  FinalCutPro FCPXML 25i.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_25i: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.`25i`.data()
    } }
    
    let projectFrameRate: TimecodeFrameRate = .fps25
    
    // MARK: - Resources
    
    let r1 = FinalCutPro.FCPXML.Format(
        id: "r1",
        name: "FFVideoFormatDV720x576i50",
        frameDuration: Fraction(200, 5000),
        fieldOrder: "lower first",
        width: 720,
        height: 576,
        paspH: 59,
        paspV: 54,
        colorSpace: "5-1-6 (Rec. 601 (PAL))",
        projection: nil,
        stereoscopic: nil
    )
    
    let r2MediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: .originalMedia,
        sig: "554B59605B289ECE8057E7FECBC3D3D0",
        src: URL(string: "file:///Users/user/Desktop/Marker_Interlaced.fcpbundle/11-9-22/Original%20Media/Test%20Video%20(29.97%20fps).mp4")!,
        bookmark: nil
    )
    lazy var r2MetadataXML = try! XMLElement(xmlString: """
        <metadata>
            <md key="com.apple.proapps.studio.rawToLogConversion" value="0"/>
            <md key="com.apple.proapps.spotlight.kMDItemProfileName" value="HD (1-1-1)"/>
            <md key="com.apple.proapps.studio.cameraISO" value="0"/>
            <md key="com.apple.proapps.studio.cameraColorTemperature" value="0"/>
            <md key="com.apple.proapps.spotlight.kMDItemCodecs">
                <array>
                    <string>'avc1'</string>
                    <string>MPEG-4 AAC</string>
                </array>
            </md>
            <md key="com.apple.proapps.mio.ingestDate" value="2022-09-10 19:25:11 -0700"/>
        </metadata>
        """
    )
    lazy var r2Metadata = FinalCutPro.FCPXML.Metadata(element: r2MetadataXML)
    lazy var r2 = FinalCutPro.FCPXML.Asset(
        id: "r2",
        name: "Test Video (29.97 fps)",
        start: .zero,
        duration: Fraction(101869, 1000),
        format: "r3",
        uid: "554B59605B289ECE8057E7FECBC3D3D0",
        hasAudio: true,
        hasVideo: true,
        audioSources: 1,
        audioChannels: 2,
        audioRate: .rate48kHz,
        videoSources: 1,
        auxVideoFlags: nil,
        mediaRep: r2MediaRep,
        metadata: r2Metadata
    )
    
    let r3 = FinalCutPro.FCPXML.Format(
        id: "r3",
        name: "FFVideoFormat1080p2997",
        frameDuration: Fraction(1001, 30000),
        fieldOrder: nil,
        width: 1920,
        height: 1080,
        paspH: nil,
        paspV: nil,
        colorSpace: "1-1-1 (Rec. 709)",
        projection: nil,
        stereoscopic: nil
    )
    
    let r4SequenceXML = try! XMLElement(xmlString: """
        <sequence format="r3" duration="174174/30000s" tcStart="0s" tcFormat="NDF" audioLayout="stereo" audioRate="48k">
        <spine>
            <asset-clip ref="r2" offset="0s" name="Media Clip" start="452452/30000s" duration="174174/30000s" tcFormat="NDF" audioRole="dialogue">
                <marker start="247247/15000s" duration="1001/30000s" value="Marker 5"/>
                <marker start="181181/10000s" duration="1001/30000s" value="Marker 6"/>
                <marker start="49049/2500s" duration="1001/30000s" value="Marker 7"/>
            </asset-clip>
        </spine>
        </sequence>
        """
    )
    lazy var r4Sequence = try! #require(FinalCutPro.FCPXML.Sequence(element: r4SequenceXML))
    lazy var r4 = FinalCutPro.FCPXML.Media(
        id: "r4",
        name: "29.97_CC",
        uid: "GYR/OKBAQ/2tErV+GGXCuA",
        modDate: "2022-09-10 23:08:42 -0700",
        sequence: r4Sequence
    )
    
    let r5 = FinalCutPro.FCPXML.Effect(
        id: "r5",
        name: "Black & White",
        uid: ".../Effects.localized/Color.localized/Black & White.localized/Black & White.moef",
        src: nil
    )
    
    let r6 = FinalCutPro.FCPXML.Effect(
        id: "r6",
        name: "Colorize",
        uid: ".../Effects.localized/Color.localized/Colorize.localized/Colorize.moef",
        src: nil
    )
    
    // MARK: - Tests
    
    /// Tests:
    /// - nested `spine`s
    /// - `media` resources containing a compound clip
    /// - `ref-clip` clips
    /// - mixed frame rates
    /// - that fraction time values that have subframes correctly convert to Timecode
    @Test
    mutating func parse() async throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        #expect(fcpxml.version == .ver1_10)
        
        // resources
        let resourcesDict = fcpxml.root.resourcesDict
        #expect(resourcesDict.count == 6)
        #expect(try #require(resourcesDict["r1"]?.fcpAsFormat) == r1)
        #expect(try #require(resourcesDict["r2"]?.fcpAsAsset) == r2)
        #expect(try #require(resourcesDict["r3"]?.fcpAsFormat) == r3)
        #expect(try #require(resourcesDict["r4"]?.fcpAsMedia) == r4)
        #expect(try #require(resourcesDict["r5"]?.fcpAsEffect) == r5)
        #expect(try #require(resourcesDict["r6"]?.fcpAsEffect) == r6)
        
        // library
        let library = try #require(fcpxml.root.library)
        let libraryURL = URL(string: "file:///Users/user/Desktop/Marker_Interlaced.fcpbundle/")
        #expect(library.location == libraryURL)
        
        // event
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "11-9-22")
        
        // project
        let projects = event.projects.zeroIndexed
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        #expect(project.name == "25i_V1")
        #expect(
            try project.startTimecode()
                == Timecode(.rational(0, 1), at: projectFrameRate, base: .max80SubFrames)
        )
        
        // sequence
        let sequence = try #require(projects[safe: 0]).sequence
        #expect(sequence.format == "r1")
        #expect(sequence.tcStartAsTimecode() == Self.tc("00:00:00:00", projectFrameRate))
        #expect(sequence.tcStartAsTimecode()?.frameRate == projectFrameRate)
        #expect(sequence.tcStartAsTimecode()?.subFramesBase == .max80SubFrames)
        #expect(sequence.durationAsTimecode() == Self.tc("00:00:29:13", projectFrameRate))
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        
        // spine
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 7)
        
        // story elements
        let element1 = try #require(storyElements[safe: 0]?.fcpAsAssetClip)
        #expect(element1.ref == "r2")
        #expect(element1.offsetAsTimecode() == Self.tc("00:00:00:00", .fps29_97))
        #expect(element1.offsetAsTimecode()?.frameRate == .fps29_97)
        #expect(element1.name == "Clip 1")
        #expect(element1.startAsTimecode() == nil)
        #expect(element1.durationAsTimecode() == Self.tc("00:00:03:11.71", .fps29_97))
        #expect(element1.durationAsTimecode()?.frameRate == .fps29_97)
        #expect( // compare to parent's frame rate
            element1.durationAsTimecode(frameRateSource: .rate(projectFrameRate))
                == Self.tc("00:00:03:10", projectFrameRate) // confirmed in FCP
        )
        #expect(element1.audioRole?.rawValue == "dialogue")
        
        // markers
        let markers = element1.element
            .children(whereFCPElement: .marker)
            .zeroIndexed
        #expect(markers.count == 1)
        
        let marker = try #require(markers[safe: 0])
        #expect(marker.name == "Marker 2")
        #expect(marker.configuration == .standard)
        #expect(
            marker.startAsTimecode(frameRateSource: .rate(projectFrameRate)) // (local timeline is 29.97)
                == Self.tc("00:00:01:11.56", projectFrameRate) // confirmed in FCP
        )
        #expect(marker.durationAsTimecode() == Self.tc("00:00:00:01", .fps29_97))
        #expect(marker.note == nil)
    }
    
    /// Check markers within `ref-clip`s.
    /// The clips within the `ref-clip` can contain markers but they don't show on the FCP timeline.
    @Test
    func extractMarkers_IncludeMarkersWithinRefClips() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try #require(fcpxml.allProjects().first)
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: .deep())
            .zeroIndexed
        
        let markers = extractedMarkers.sortedByAbsoluteStartTimecode()
        
        #expect(markers.count == 18 + (2 * 3))
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // check frame rate of Timecode from perspective of the main timeline
        #expect(markers.allSatisfy {
            $0.timecode(frameRateSource: .mainTimeline)?.frameRate == projectFrameRate
        })
        
        // Clip 1
        
        #expect(markers[safe: 0]?.name == "Marker 2")
        let marker2Timecode = try #require(markers[safe: 0]?.timecode())
        #expect(marker2Timecode == Self.tc("00:00:01:11.56", projectFrameRate))
        #expect(marker2Timecode.frameRate == projectFrameRate)
        
        // Clip 2
        #expect(markers[safe: 1]?.name == "Marker 3")
        let marker3Timecode = try #require(markers[safe: 1]?.timecode())
        #expect(marker3Timecode == Self.tc("00:00:04:05.68", projectFrameRate))
        #expect(marker3Timecode.frameRate == projectFrameRate)
        
        // Clip 2
        #expect(markers[safe: 2]?.name == "Marker 4")
        let marker4Timecode = try #require(markers[safe: 2]?.timecode())
        #expect(marker4Timecode == Self.tc("00:00:05:20.71", projectFrameRate))
        #expect(marker4Timecode.frameRate == projectFrameRate)
        
        // Media Clip
        #expect(markers[safe: 3]?.name == "Marker 5")
        let marker5Timecode = try #require(markers[safe: 3]?.timecode())
        #expect(marker5Timecode == Self.tc("00:00:06:23", projectFrameRate) + Self.tc("00:00:01:12", .fps29_97))
        #expect(marker5Timecode.frameRate == projectFrameRate)
        
        // Media Clip
        #expect(markers[safe: 4]?.name == "Marker 6")
        let marker6Timecode = try #require(markers[safe: 4]?.timecode())
        #expect(marker6Timecode == Self.tc("00:00:06:23", projectFrameRate) + Self.tc("00:00:03:01", .fps29_97))
        #expect(marker6Timecode.frameRate == projectFrameRate)
        
        // Media Clip - technically out of bounds of the ref-clip
        #expect(markers[safe: 5]?.name == "Marker 7")
        let marker7Timecode = try #require(markers[safe: 5]?.timecode())
        #expect(marker7Timecode == Self.tc("00:00:06:23", projectFrameRate) + Self.tc("00:00:04:16", .fps29_97))
        #expect(marker7Timecode.frameRate == projectFrameRate)
        
        // Clip 4
        #expect(markers[safe: 6]?.name == "Marker 8")
        let marker8Timecode = try #require(markers[6].timecode())
        #expect(marker8Timecode == Self.tc("00:00:11:18.19", projectFrameRate))
        #expect(marker8Timecode.frameRate == projectFrameRate)
        
        // Clip 4
        #expect(markers[safe: 7]?.name == "Marker 9")
        let marker9Timecode = try #require(markers[7].timecode())
        #expect(marker9Timecode == Self.tc("00:00:12:24.75", projectFrameRate))
        #expect(marker9Timecode.frameRate == projectFrameRate)
        
        // Clip 5
        #expect(markers[safe: 8]?.name == "Marker 1")
        let marker1Timecode = try #require(markers[8].timecode())
        #expect(marker1Timecode == Self.tc("00:00:14:03.54", projectFrameRate))
        #expect(marker1Timecode.frameRate == projectFrameRate)
        
        // Clip 5
        #expect(markers[safe: 9]?.name == "Marker 10")
        let marker10Timecode = try #require(markers[9].timecode())
        #expect(marker10Timecode == Self.tc("00:00:14:07.67", projectFrameRate))
        #expect(marker10Timecode.frameRate == projectFrameRate)
        
        // Clip 5
        #expect(markers[safe: 10]?.name == "Marker 11")
        let marker11Timecode = try #require(markers[safe: 10]?.timecode())
        #expect(marker11Timecode == Self.tc("00:00:14:13.54", projectFrameRate))
        #expect(marker11Timecode.frameRate == projectFrameRate)
        
        // Clip 5 - FCP shows 00:00:14:19.42
        #expect(markers[safe: 11]?.name == "Marker 12")
        let marker12Timecode = try #require(markers[safe: 11]?.timecode())
        #expect(
            try marker12Timecode
            == Self.tc("00:00:14:19.42", projectFrameRate)
                .subtracting(.frames(0, subFrames: 1)) // TODO: subframe aliasing/rounding
        )
        #expect(marker12Timecode.frameRate == projectFrameRate)
        
        // Clip 5.2
        #expect(markers[safe: 12]?.name == "Marker 14")
        let marker14Timecode = try #require(markers[safe: 12]?.timecode())
        #expect(marker14Timecode == Self.tc("00:00:14:23.53", projectFrameRate))
        #expect(marker14Timecode.frameRate == projectFrameRate)
        
        // Clip 5.2
        #expect(markers[safe: 13]?.name == "Marker 15")
        let marker15Timecode = try #require(markers[safe: 13]?.timecode())
        #expect(marker15Timecode == Self.tc("00:00:15:02.00", projectFrameRate))
        #expect(marker15Timecode.frameRate == projectFrameRate)
        
        // Clip 5
        #expect(markers[safe: 14]?.name == "Marker 16")
        let marker16Timecode = try #require(markers[safe: 14]?.timecode())
        #expect(marker16Timecode == Self.tc("00:00:15:10.29", projectFrameRate))
        #expect(marker16Timecode.frameRate == projectFrameRate)
        
        // Clip 5.2
        #expect(markers[safe: 15]?.name == "Marker 17")
        let marker17Timecode = try #require(markers[safe: 15]?.timecode())
        #expect(marker17Timecode == Self.tc("00:00:15:14.27", projectFrameRate))
        #expect(marker17Timecode.frameRate == projectFrameRate)
        
        // Clip 6
        #expect(markers[safe: 16]?.name == "Marker 18")
        let marker18Timecode = try #require(markers[safe: 16]?.timecode())
        #expect(marker18Timecode == Self.tc("00:00:19:20.20", projectFrameRate))
        #expect(marker18Timecode.frameRate == projectFrameRate)
        
        // Clip 6
        #expect(markers[safe: 17]?.name == "Marker 19")
        let marker19Timecode = try #require(markers[safe: 17]?.timecode())
        #expect(marker19Timecode == Self.tc("00:00:21:16.77", projectFrameRate))
        #expect(marker19Timecode.frameRate == projectFrameRate)
        
        // Clip 7
        #expect(markers[safe: 18]?.name == "Marker 20")
        let marker20Timecode = try #require(markers[safe: 18]?.timecode())
        #expect(marker20Timecode == Self.tc("00:00:24:06.56", projectFrameRate))
        #expect(marker20Timecode.frameRate == projectFrameRate)
        
        // Media Clip - FCP shows 00:00:24:19.03 @ 25 fps
        #expect(markers[safe: 19]?.name == "Marker 5")
        let marker5BTimecode = try #require(markers[safe: 19]?.timecode())
        #expect(marker5BTimecode == Self.tc("00:00:23:09", projectFrameRate) + Self.tc("00:00:01:12", .fps29_97))
        #expect(marker5BTimecode.frameRate == projectFrameRate)
        
        // Media Clip - FCP shows 00:00:26:09.90 @ 25 fps, technically out of bounds of the ref-clip
        #expect(markers[safe: 20]?.name == "Marker 6")
        let marker6BTimecode = try #require(markers[safe: 20]?.timecode())
        #expect(marker6BTimecode == Self.tc("00:00:23:09", projectFrameRate) + Self.tc("00:00:03:01", .fps29_97))
        #expect(marker6BTimecode.frameRate == projectFrameRate)
        
        // Clip 7
        #expect(markers[safe: 21]?.name == "Marker 21")
        let marker21Timecode = try #require(markers[safe: 21]?.timecode())
        #expect(marker21Timecode == Self.tc("00:00:26:24.22", projectFrameRate))
        #expect(marker21Timecode.frameRate == projectFrameRate)
        
        // Media Clip - FCP shows 00:00:27:22.44 @ 25 fps, technically out of bounds of the ref-clip
        #expect(markers[safe: 22]?.name == "Marker 7")
        let marker7BTimecode = try #require(markers[safe: 22]?.timecode())
        #expect(marker7BTimecode == Self.tc("00:00:23:09", projectFrameRate) + Self.tc("00:00:04:16", .fps29_97))
        #expect(marker7BTimecode.frameRate == projectFrameRate)
        
        // Clip 7
        #expect(markers[safe: 23]?.name == "Marker 22")
        let marker22Timecode = try #require(markers[safe: 23]?.timecode())
        #expect(marker22Timecode == Self.tc("00:00:28:19.25", projectFrameRate))
        #expect(marker22Timecode.frameRate == projectFrameRate)
    }
    
    @Test
    func extractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try #require(fcpxml.allProjects().first)
        
        let markers = await project
            .extract(preset: .markers, scope: .mainTimeline)
            .sortedByAbsoluteStartTimecode()
        
        #expect(markers.count == 18)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // print("Sorted by name:")
        // print(Self.debugString(for: markers.sortedByName()))
    }
    
    /// Check markers within `ref-clip`s.
    /// The clips within the `ref-clip` can contain markers but they don't show on the FCP timeline.
    @Test
    func extractMarkers_ExcludeMarkersWithinRefClips() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try #require(fcpxml.allProjects().first)
        
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            excludedTraversalTypes: [.refClip]
        )
        let markers = await project
            .extract(preset: .markers, scope: scope)
            .sortedByAbsoluteStartTimecode()
        
        #expect(markers.count == 18)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // print("Sorted by name:")
        // print(Self.debugString(for: markers.sortedByName()))
    }
}

#endif
