//
//  FinalCutPro FCPXML 24With25Media.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_24With25Media: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.`24With25Media`.data()
    } }
    
    /// Project @ 24fps.
    /// Contains media @ 25fps.
    let projectFrameRate: TimecodeFrameRate = .fps24
    
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
        #expect(project.name == "24With25Media")
        #expect(
            try project.startTimecode()
                == Timecode(.components(h: 1), at: projectFrameRate, base: .max80SubFrames)
        )
        
        // sequence
        let sequence = try #require(projects[safe: 0]).sequence
        #expect(sequence.format == "r1")
        #expect(sequence.tcStartAsTimecode() == Self.tc("01:00:00:00", projectFrameRate))
        #expect(sequence.tcStartAsTimecode()?.frameRate == projectFrameRate)
        #expect(sequence.tcStartAsTimecode()?.subFramesBase == .max80SubFrames)
        #expect(sequence.durationAsTimecode() == Self.tc("00:02:42:23", projectFrameRate))
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        
        // spine
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 4)
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
        
        // 3 x markers
        
        struct MarkerData {
            let absTC: String // Absolute timecode, as seen in FCP
            let name: String
            let config: FinalCutPro.FCPXML.Marker.Configuration
            let occ: FinalCutPro.FCPXML.ElementOcclusion
        }
        
        // swiftformat:disable all
        let markerList: [MarkerData] = [
            MarkerData(absTC: "01:00:10:01.00", name: "Marker 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "01:02:09:17.00", name: "Marker 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "01:02:28:18.00", name: "Marker 3", config: .standard, occ: .notOccluded)
        ]
        // swiftformat:enable all
        let expectedMarkerCount = 3
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
        
        #expect(extractedMarkers.count == 3)
    }
}

#endif
