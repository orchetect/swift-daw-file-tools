//
//  FinalCutPro FCPXML CompoundClips.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_CompoundClips: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.compoundClips.data()
    } }
    
    // MARK: - Tests
    
    /// Ensure that markers directly attached to compound clips (`ref-clip`s) on the main timeline
    /// are preserved, while all markers within compound clips are discarded.
    @Test
    func extract_MainTimeline() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .mainTimeline)
            .zeroIndexed
        #expect(extractedMarkers.count == 2)
        
        // just test basic marker info to identify the marker
        let marker0 = try #require(extractedMarkers[safe: 0])
        #expect(marker0.name == "Marker On Title Compound Clip in Main Timeline")
        #expect(marker0.value(forContext: .absoluteStartAsTimecode()) == Self.tc("01:00:04:00", .fps25))
        
        let marker2 = try #require(extractedMarkers[safe: 1])
        #expect(marker2.name == "Marker On Clouds Compound Clip in Main Timeline")
        #expect(marker2.value(forContext: .absoluteStartAsTimecode()) == Self.tc("01:00:25:00", .fps25))
    }
    
    @Test
    func extract_Deep() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .deep())
            .zeroIndexed
        #expect(extractedMarkers.count == 6)
    }
    
    @Test
    func extract_allElementTypes() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(
            types: [.marker, .chapterMarker],
            scope: FinalCutPro.FCPXML.ExtractionScope(
                auditions: .all,
                mcClipAngles: .all,
                occlusions: .allCases,
                filteredTraversalTypes: [],
                excludedTraversalTypes: [],
                excludedExtractionTypes: [],
                traversalPredicate: nil,
                extractionPredicate: nil
            )
        )
        .zeroIndexed
        
        #expect(extractedMarkers.count == 6)
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
        
        let expectedMarkerCount = 2
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
        
        // marker 1
        // - compound clip has metadata, but the interior `title` clip has none
        do {
            let marker = try #require(markers[safe: 0])
            let mtdm = marker.value(forContext: .metadata)
            #expect(mtdm.count == 5)
            
            #expect(marker.name == "Marker On Title Compound Clip in Main Timeline")
            
            // metadata from media
            #expect(md(in: mtdm, key: .reel)?.value == "Title Compound Clip Reel")
            #expect(md(in: mtdm, key: .scene)?.value == "Title Compound Clip Scene")
            #expect(md(in: mtdm, key: .take)?.value == "Title Compound Clip Take")
            #expect(md(in: mtdm, key: .cameraAngle)?.value == "Title Compound Clip Camera Angle")
            #expect(md(in: mtdm, key: .cameraName)?.value == "Title Compound Clip Camera Name")
            
            // these happen to not be present probably because we're using Titles within this clip
            #expect(md(in: mtdm, key: .rawToLogConversion)?.value == nil)
            #expect(md(in: mtdm, key: .colorProfile)?.value == nil)
            #expect(md(in: mtdm, key: .cameraISO)?.value == nil)
            #expect(md(in: mtdm, key: .cameraColorTemperature)?.value == nil)
            #expect(md(in: mtdm, key: .codecs)?.valueArray == nil)
            #expect(md(in: mtdm, key: .ingestDate)?.value == nil)
        }
        
        // marker 2
        // - compound clip itself has no metadata, but both internal clips have metadata in FCP.
        // - however, FCP doesn't seem to export the metadata in the XML for titles and generators.
        // - this marker happens to overlay on a portion of the compound clip where the internal clip
        //   does have its metadata present in the XML however.
        do {
            let marker = try #require(markers[safe: 1])
            let mtdm = marker.value(forContext: .metadata)
            #expect(mtdm.count == 0)
            
            #expect(marker.name == "Marker On Clouds Compound Clip in Main Timeline")
            
            // metadata from media
            #expect(md(in: mtdm, key: .reel)?.value == nil)
            #expect(md(in: mtdm, key: .scene)?.value == nil)
            #expect(md(in: mtdm, key: .take)?.value == nil)
            #expect(md(in: mtdm, key: .cameraAngle)?.value == nil)
            #expect(md(in: mtdm, key: .cameraName)?.value == nil)
            
            // these happen to not be present probably because we're using Titles within this clip
            #expect(md(in: mtdm, key: .rawToLogConversion)?.value == nil)
            #expect(md(in: mtdm, key: .colorProfile)?.value == nil)
            #expect(md(in: mtdm, key: .cameraISO)?.value == nil)
            #expect(md(in: mtdm, key: .cameraColorTemperature)?.value == nil)
            #expect(md(in: mtdm, key: .codecs)?.valueArray == nil)
            #expect(md(in: mtdm, key: .ingestDate)?.value == nil)
        }
    }
}

#endif
