//
//  FinalCutPro FCPXML AuditionMarkers3.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_AuditionMarkers3: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.auditionMarkers3.data()
    } }
    
    // MARK: - Tests
    
    @Test
    func parse() async throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        #expect(fcpxml.version == .ver1_11)
        
        // resources
        let resourcesDict = fcpxml.root.resourcesDict
        #expect(resourcesDict.count == 7)
        
        // library
        let library = try #require(fcpxml.root.library)
        let libraryURL = URL(string: "file:///Users/user/Movies/FCPXMLTest.fcpbundle/")
        #expect(library.location == libraryURL)
        
        // event
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "Test Event")
        
        // project
        let projects = event.projects.zeroIndexed
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        #expect(project.name == "Test Project")
        #expect(project.startTimecode() == Self.tc("00:00:00:00", .fps23_976))
        
        // sequence
        let sequence = try #require(projects[safe: 0]).sequence
        #expect(sequence.format == "r1")
        #expect(sequence.tcStartAsTimecode() == Self.tc("00:00:00:00", .fps23_976))
        #expect(sequence.tcStartAsTimecode()?.frameRate == .fps23_976)
        #expect(sequence.tcStartAsTimecode()?.subFramesBase == .max80SubFrames)
        #expect(sequence.durationAsTimecode() == Self.tc("00:00:59:17", .fps23_976))
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        
        // spine
        let spine = sequence.spine
        
        let contents = spine.contents.zeroIndexed
        #expect(contents.count == 3)
        
        // story elements
        let audition = try #require(contents[safe: 2]?.fcpAsAudition)
        #expect(audition.lane == nil)
        #expect(audition.offsetAsTimecode() == Self.tc("00:00:31:16", .fps23_976))
        #expect(audition.offsetAsTimecode()?.frameRate == .fps23_976)
        
        let activeAudition = try #require(audition.activeClip)
        
        // markers
        let markers = activeAudition
            .children(whereFCPElement: .marker)
            .zeroIndexed
        #expect(markers.count == 3)
        
        let marker0 = try #require(markers[safe: 0])
        #expect(marker0.name == "Audition 1")
        #expect(marker0.configuration == .standard)
        #expect(
            marker0.startAsTimecode(frameRateSource: .mainTimeline) // local clip timeline is 25fps
                == Self.tc("00:00:07:09", .fps23_976) // confirmed in FCP
        )
        #expect(
            marker0.durationAsTimecode(frameRateSource: .mainTimeline)
                == Self.tc("00:00:00:01.03", .fps23_976) // 1 frame, scaled
        )
        #expect(marker0.note == nil)
        
        let marker1 = try #require(markers[safe: 1])
        #expect(marker1.name == "Audition 2")
        #expect(marker1.configuration == .standard)
        #expect(
            marker1.startAsTimecode(frameRateSource: .mainTimeline) // local clip timeline is 25fps
                == Self.tc("00:00:14:08", .fps23_976) // confirmed in FCP
        )
        #expect(
            marker1.durationAsTimecode(frameRateSource: .mainTimeline)
                == Self.tc("00:00:00:01.03", .fps23_976) // 1 frame, scaled
        )
        #expect(marker1.note == nil)
        
        let marker2 = try #require(markers[safe: 2])
        #expect(marker2.name == "Audition 3")
        #expect(marker2.configuration == .standard)
        #expect(
            marker2.startAsTimecode(frameRateSource: .mainTimeline) // local clip timeline is 25fps
                == Self.tc("00:00:22:22", .fps23_976) // confirmed in FCP
        )
        #expect(
            marker2.durationAsTimecode(frameRateSource: .mainTimeline)
                == Self.tc("00:00:00:01.03", .fps23_976) // 1 frame, scaled
        )
        #expect(marker2.note == nil)
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
        
        #expect(markers.count == 4)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // just test audition markers
        
        let marker0 = try #require(markers[safe: 1])
        #expect(marker0.name == "Audition 1") // just to identify marker
        #expect(marker0.timecode() == Self.tc("00:00:39:01", .fps23_976))
        
        let marker1 = try #require(markers[safe: 2])
        #expect(marker1.name == "Audition 2") // just to identify marker
        #expect(marker1.timecode() == Self.tc("00:00:46:00", .fps23_976))
        
        let marker2 = try #require(markers[safe: 3])
        #expect(marker2.name == "Audition 3") // just to identify marker
        #expect(marker2.timecode() == Self.tc("00:00:54:14", .fps23_976))
    }
    
    /// Test metadata that applies to marker(s).
    @Test
    func extractMarkersMetadata_MainTimeline() async throws {
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
        
        let expectedMarkerCount = 4
        #expect(markers.count == expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // markers
        
        func md(
            in mdtm: [FinalCutPro.FCPXML.Metadata.Metadatum],
            key: FinalCutPro.FCPXML.Metadata.Key
        ) -> FinalCutPro.FCPXML.Metadata.Metadatum? {
            let matches = mdtm.filter { $0.key == key }
            #expect(matches.count < 2)
            return matches.first
        }
        
        // skip testing marker 1, it's not on an audition clip
        
        // marker 2
        do {
            let marker = try #require(markers[safe: 1])
            let mtdm = marker.value(forContext: .metadata)
            #expect(mtdm.count == 11)
            
            #expect(marker.name == "Audition 1")
            
            // metadata from active audition clip
            #expect(md(in: mtdm, key: .reel)?.value == "TestVideo2 Reel")
            #expect(md(in: mtdm, key: .scene)?.value == "TestVideo2 Scene")
            #expect(md(in: mtdm, key: .take)?.value == "TestVideo2 Take")
            #expect(md(in: mtdm, key: .cameraAngle)?.value == "TestVideo2 Camera Angle")
            
            // metadata from active clip's resource
            #expect(md(in: mtdm, key: .rawToLogConversion)?.value == "0")
            #expect(md(in: mtdm, key: .colorProfile)?.value == "HD (1-1-1)")
            #expect(md(in: mtdm, key: .cameraISO)?.value == "0")
            #expect(md(in: mtdm, key: .cameraColorTemperature)?.value == "0")
            #expect(md(in: mtdm, key: .codecs)?.valueArray == ["'avc1'", "MPEG-4 AAC"])
            #expect(md(in: mtdm, key: .ingestDate)?.value == "2023-11-22 04:01:31 -0800")
            #expect(md(in: mtdm, key: .cameraName)?.value == "TestVideo2 Camera Name")
        }
    }
}

#endif
