//
//  FinalCutPro FCPXML ClipMetadata.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_ClipMetadata: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.clipMetadata.data()
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
    }
    
    /// Test metadata that applies to marker(s).
    @Test
    func extractMarkersMetadata() async throws {
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
        
        let expectedMarkerCount = 1
        #expect(markers.count == expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // markers
        
        let marker1 = try #require(markers[safe: 0])
        
        let metadata = marker1.value(forContext: .metadata)
        
        #expect(metadata.count == 11)
        
        func md(key: FinalCutPro.FCPXML.Metadata.Key) -> FinalCutPro.FCPXML.Metadata.Metadatum? {
            let matches = metadata.filter { $0.key == key }
            #expect(matches.count < 2)
            return matches.first
        }
        
        // metadata from media
        #expect(md(key: .cameraName)?.value == "TestVideo Camera Name")
        #expect(md(key: .rawToLogConversion)?.value == "0")
        #expect(md(key: .colorProfile)?.value == "SD (6-1-6)")
        #expect(md(key: .cameraISO)?.value == "0")
        #expect(md(key: .cameraColorTemperature)?.value == "0")
        #expect(md(key: .codecs)?.valueArray == ["'avc1'", "MPEG-4 AAC"])
        #expect(md(key: .ingestDate)?.value == "2023-01-01 19:46:28 -0800")
        // metadata from clip
        #expect(md(key: .reel)?.value == "TestVideo Reel")
        #expect(md(key: .scene)?.value == "TestVideo Scene")
        #expect(md(key: .take)?.value == "TestVideo Take")
        #expect(md(key: .cameraAngle)?.value == "TestVideo Camera Angle")
    }
}

#endif
