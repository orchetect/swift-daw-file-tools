//
//  FinalCutPro FCPXML DisabledClips.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_DisabledClips: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.disabledClips.data()
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
        #expect(fcpxml.version == .ver1_11)
        
        // skip testing file contents, we only care about roles assigned to markers for these tests
    }
    
    @Test
    func extractMarkers_IncludeDisabledClips() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try #require(fcpxml.allProjects().first)
        
        var scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
        scope.includeDisabled = true
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: scope)
            .sortedByAbsoluteStartTimecode()
            // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 4
        #expect(markers.count == expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // Titles clips should never have an audio role
        
        let marker1 = try #require(markers[safe: 0])
        #expect(marker1.name == "Marker 1")
        
        let marker2 = try #require(markers[safe: 1])
        #expect(marker2.name == "Marker 2")
        
        let marker3 = try #require(markers[safe: 2])
        #expect(marker3.name == "Marker 3")
        
        let marker4 = try #require(markers[safe: 3])
        #expect(marker4.name == "Marker 4")
    }
    
    @Test
    func extractMarkers_ExcludeDisabledClips() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try #require(fcpxml.allProjects().first)
        
        var scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
        scope.includeDisabled = false
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: scope)
            .sortedByAbsoluteStartTimecode()
        // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 2
        #expect(markers.count == expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // Titles clips should never have an audio role
        
        let marker1 = try #require(markers[safe: 0])
        #expect(marker1.name == "Marker 1")
        
        let marker3 = try #require(markers[safe: 1])
        #expect(marker3.name == "Marker 3")
    }
}

#endif
