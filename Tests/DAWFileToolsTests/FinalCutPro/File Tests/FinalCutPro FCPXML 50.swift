//
//  FinalCutPro FCPXML 50.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_50: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.`50`.data()
    } }
    
    /// Project @ 50fps.
    /// Contains media @ 23.976fps and 29.97fps.
    let projectFrameRate: TimecodeFrameRate = .fps50
    
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
        #expect(resourcesDict.count == 8)
        
        // library
        let library = try #require(fcpxml.root.library)
        let libraryURL = URL(string: "file:///Users/user/Movies/FCPXMLTest.fcpbundle/")
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
        #expect(project.name == "50_V1")
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
        #expect(sequence.durationAsTimecode() == Self.tc("00:04:12:41", projectFrameRate))
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        
        // spine
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 16)
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
            .extract(preset: .markers, scope: .deep())
            .sortedByAbsoluteStartTimecode()
            // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        // 3 x markers in r8 media resource (resource is used once which produces 3 markers)
        // 24 x markers in sequence
        
        struct MarkerData {
            let absTC: String // Absolute timecode, as seen in FCP
            let name: String
            let config: FinalCutPro.FCPXML.Marker.Configuration
            let occ: FinalCutPro.FCPXML.ElementOcclusion
        }
        
        // swiftformat:disable all
        let markerList: [MarkerData] = [
            MarkerData(absTC: "00:00:16:29.02", name: "Shot_01", config: .toDo(completed: false), occ: .notOccluded), // off by 1 subframe
            MarkerData(absTC: "00:00:52:12.62", name: "Shot_02", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:01:26:30.46", name: "Shot_03", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:01:53:33.53", name: "Shot_04", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:10:36.19", name: "Shot_05", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:02:18:22.73", name: "Shot_06", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:24:08.78", name: "Shot_07", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:17:07.30", name: "Shot_08", config: .chapter(posterOffset: Fraction(11, 24)), occ: .notOccluded),
            MarkerData(absTC: "00:03:36:12.61", name: "Shot_09", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:44:43.62", name: "Shot_10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:55:10.32", name: "Marker 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:58:01.29", name: "Marker 3", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:59:31.36", name: "Marker 4", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:02:04.05", name: "INSIDE 1", config: .standard, occ: .notOccluded),   // 00:04:00:34 @ 50 + 00:00:01:12 @ 29.97
            MarkerData(absTC: "00:04:03:35.65", name: "INSIDE 2", config: .standard, occ: .notOccluded),   // 00:04:00:34 @ 50 + 00:00:03:01 @ 29.97
            MarkerData(absTC: "00:04:05:10.71", name: "INSIDE 3", config: .standard, occ: .fullyOccluded), // 00:04:00:34 @ 50 + 00:00:04:16 @ 29.97
            
            MarkerData(absTC: "00:04:05:26.12", name: "Marker 8", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:06:39.44", name: "Marker 9", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:07:45.28", name: "Marker 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:03.55", name: "Marker 10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:15.29", name: "Marker 11", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:27.03", name: "Marker 12", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:28.00", name: "Marker 13", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:36.26", name: "Marker 14", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:43.00", name: "Marker 15", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:09:08.59", name: "Marker 16", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:09:21.26", name: "Marker 17", config: .standard, occ: .notOccluded), // off by 1 subframe
        ]
        // swiftformat:enable all
        let expectedMarkerCount = 24 + 3
        assert(markerList.count == expectedMarkerCount) // unit test sanity check
        
        #expect(markers.count == expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        for (index, markerData) in markerList.enumerated() {
            let marker = try #require(markers[safe: index])
            let desc = marker.name
            
            // name
            guard marker.name == markerData.name else {
                Issue.record(
                    "Fail: marker name mismatch at index \(index). Expected \(markerData.name.quoted) but found \(marker.name.quoted)."
                )
                continue
            }
            
            // config
            #expect(marker.configuration == markerData.config, "\(desc)")
            
            // absolute timecode
            let tc = try #require(marker.timecode(), "\(marker.name)")
            #expect(tc == Self.tc(markerData.absTC, projectFrameRate), "\(desc)")
            #expect(tc.frameRate == projectFrameRate, "\(desc)")
            
            // occlusion
            #expect(marker.value(forContext: .effectiveOcclusion) == markerData.occ, "\(desc)")
        }
    }
    
    /// Just check that the correct number of markers are extracted for main timeline.
    @Test
    func extractMarkers_MainTimeline() async throws {
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
        
        #expect(extractedMarkers.count == 24)
    }
}

#endif
