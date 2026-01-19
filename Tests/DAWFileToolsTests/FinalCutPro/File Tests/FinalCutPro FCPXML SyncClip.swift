//
//  FinalCutPro FCPXML SyncClip.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_SyncClip: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.syncClip.data()
    } }
    
    // MARK: - Tests
    
    /// Ensure that elements that can appear in various locations in the XML hierarchy are all found.
    @Test
    func parse() async throws {
        // load file
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "TestEvent")
        
        // project
        let projects = event.projects.zeroIndexed
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        
        // sequence
        let sequence = project.sequence
        
        // spine
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 1)
        
        // story elements
        let syncClip = try #require(storyElements[safe: 0]?.fcpAsSyncClip)
        #expect(syncClip.format == "r2")
        #expect(syncClip.offsetAsTimecode() == Self.tc("01:00:00:00", .fps25))
        #expect(syncClip.offsetAsTimecode()?.frameRate == .fps25)
        #expect(syncClip.name == "TestVideo - Synchronized Clip")
        #expect(syncClip.startAsTimecode() == nil)
        #expect(syncClip.durationAsTimecode() == Self.tc("00:00:29:13", .fps25))
        #expect(syncClip.durationAsTimecode()?.frameRate == .fps25)
        
        // let syncClipStoryElements = syncClip.storyElements.zeroIndexed
        //
        // let assetClip = try #require(syncClipStoryElements[safe: 0]?.fcpAsAssetClip)
    }
    
    /// Test main timeline markers extraction.
    @Test
    func extractMarkers_MainTimeline() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .mainTimeline)
            .zeroIndexed
        #expect(extractedMarkers.count == 1)
        
        let marker = try #require(extractedMarkers[safe: 0])
        #expect(marker.name == "Marker on Sync Clip")
        #expect(marker.timecode() == Self.tc("01:00:10:00", .fps25))
        #expect(marker.value(forContext: .occlusion) == .notOccluded)
        #expect(marker.value(forContext: .effectiveOcclusion) == .notOccluded)
        #expect(marker.value(forContext: .inheritedRoles) == [
            .inherited(.video(raw: "Sample Role")!), // markers can never have 'assigned' roles
            .inherited(.audio(raw: "effects.effects-1")!) // markers can never have 'assigned' roles
        ])
    }
    
    /// Test deep markers extraction.
    @Test
    func extractMarkers_Deep() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .deep())
            .zeroIndexed
        #expect(extractedMarkers.count == 3)
        
        // In FCP, a Sync Clip does not bear roles itself.
        // Instead, it inherits the video and audio role of the asset clip(s) within it.
        
        let marker0 = try #require(extractedMarkers[safe: 0])
        #expect(marker0.name == "Marker on Audio")
        #expect(marker0.model.startAsTimecode() == Self.tc("00:00:03:00", .fps25))
        #expect(marker0.timecode() == Self.tc("01:00:03:00", .fps25))
        #expect(marker0.value(forContext: .occlusion) == .notOccluded)
        #expect(marker0.value(forContext: .effectiveOcclusion) == .notOccluded)
        #expect(marker0.value(forContext: .inheritedRoles) == [
            .inherited(.video(raw: "Sample Role")!), // markers can never have 'assigned' roles
            .inherited(.audio(raw: "effects.effects-1")!) // markers can never have 'assigned' roles
        ])
        
        let marker1 = try #require(extractedMarkers[safe: 1])
        #expect(marker1.name == "Marker on TestVideo")
        #expect(marker1.model.startAsTimecode() == Self.tc("00:00:27:10", .fps25))
        #expect(marker1.timecode() == Self.tc("01:00:27:10", .fps25))
        #expect(marker1.value(forContext: .occlusion) == .notOccluded)
        #expect(marker1.value(forContext: .effectiveOcclusion) == .notOccluded)
        #expect(marker1.value(forContext: .inheritedRoles) == [
            .inherited(.video(raw: "Sample Role")!), // markers can never have 'assigned' roles
            .inherited(.audio(raw: "music.music-1")!) // markers can never have 'assigned' roles
        ])
        
        // sync clip does not have video/audio roles nor does its parents.
        // instead, we derive the video role from the sync clip's contents.
        // the audio role may be present in a `sync-source` child of the sync clip.
        let marker2 = try #require(extractedMarkers[safe: 2])
        #expect(marker2.name == "Marker on Sync Clip")
        #expect(marker2.model.startAsTimecode() == Self.tc("00:00:10:00", .fps25))
        #expect(marker2.timecode() == Self.tc("01:00:10:00", .fps25))
        #expect(marker2.value(forContext: .occlusion) == .notOccluded)
        #expect(marker2.value(forContext: .effectiveOcclusion) == .notOccluded)
        #expect(marker2.value(forContext: .inheritedRoles) == [
            .inherited(.video(raw: "Sample Role")!), // markers can never have 'assigned' roles
            .inherited(.audio(raw: "effects.effects-1")!) // markers can never have 'assigned' roles
        ])
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
        
        let expectedMarkerCount = 1
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
        do {
            let marker = try #require(markers[safe: 0])
            let mtdm = marker.value(forContext: .metadata)
            #expect(mtdm.count == 11)
            
            #expect(marker.name == "Marker on Sync Clip")
            
            // metadata from media
            #expect(md(in: mtdm, key: .cameraName)?.value == "TestVideo Camera Name")
            #expect(md(in: mtdm, key: .rawToLogConversion)?.value == "0")
            #expect(md(in: mtdm, key: .colorProfile)?.value == "SD (6-1-6)")
            #expect(md(in: mtdm, key: .cameraISO)?.value == "0")
            #expect(md(in: mtdm, key: .cameraColorTemperature)?.value == "0")
            #expect(md(in: mtdm, key: .codecs)?.valueArray == ["'avc1'", "MPEG-4 AAC"])
            #expect(md(in: mtdm, key: .ingestDate)?.value == "2023-01-01 19:46:28 -0800")
            // metadata from clip
            #expect(md(in: mtdm, key: .reel)?.value == "SyncClip Reel")
            #expect(md(in: mtdm, key: .scene)?.value == "SyncClip Scene")
            #expect(md(in: mtdm, key: .take)?.value == "SyncClip Take")
            #expect(md(in: mtdm, key: .cameraAngle)?.value == "SyncClip Camera Angle")
        }
    }
}

#endif
