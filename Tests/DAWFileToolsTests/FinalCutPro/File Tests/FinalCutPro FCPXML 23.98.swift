//
//  FinalCutPro FCPXML 23.98.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_23_98: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.`23.98`.data()
    } }
    
    /// Project @ 23.976fps.
    /// Contains media @ 23.976fps and 29.97fps.
    let projectFrameRate: TimecodeFrameRate = .fps23_976
    
    // MARK: - Tests
    
    @Test
    func parse() async throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        #expect(fcpxml.version == .ver1_11)
        
        // event
        let events = fcpxml.allEvents()
        let event = try #require(events[safe: 0])
        
        // project
        let projects = event.projects.zeroIndexed
        let project = try #require(projects[safe: 0])
        #expect(project.name == "23.98_V1")
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
        #expect(sequence.durationAsTimecode() == Self.tc("00:03:42:20", projectFrameRate))
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        
        // spine
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 8)
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
        
        // 12 x markers in sequence
        
        struct MarkerData {
            let absTC: String // Absolute timecode, as seen in FCP
            let name: String
            let config: FinalCutPro.FCPXML.Marker.Configuration
            let occ: FinalCutPro.FCPXML.ElementOcclusion
        }
        
        // swiftformat:disable all
        let markerList: [MarkerData] = [
            MarkerData(absTC: "00:00:16:14.00", name: "Shot_01", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:00:39:01.00", name: "Audition 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:46:00.00", name: "Audition 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:52:05.00", name: "Shot_02", config: .toDo(completed: false), occ: .notOccluded), // hidden in main timeline; in first alt audition
            MarkerData(absTC: "00:00:54:14.00", name: "Audition 3", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:01:15:22.00", name: "Shot_03", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:01:42:21.00", name: "Shot_04", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:01:59:21.00", name: "Shot_05", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:02:07:13.00", name: "Shot_06", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:13:06.00", name: "Shot_07", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:06:06.00", name: "Shot_08", config: .chapter(posterOffset: Fraction(11, 24)), occ: .notOccluded),
            MarkerData(absTC: "00:03:25:07.00", name: "Shot_09", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:34:06.00", name: "Shot_10", config: .standard, occ: .notOccluded)
        ]
        // swiftformat:enable all
        let expectedMarkerCount = 13
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
        
        #expect(extractedMarkers.count == 12)
    }
}

#endif
