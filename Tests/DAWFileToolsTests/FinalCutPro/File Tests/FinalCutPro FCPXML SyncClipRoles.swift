//
//  FinalCutPro FCPXML SyncClipRoles.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_SyncClipRoles: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.syncClipRoles.data()
    } }
    
    // MARK: - Tests
    
    /// Ensure that elements that can appear in various locations in the XML hierarchy are all found.
    @Test
    func parse() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // events
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        
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
        let clip1 = try #require(storyElements[safe: 0]?.fcpAsSyncClip)
        #expect(clip1.format == nil)
        #expect(clip1.offsetAsTimecode() == Self.tc("01:01:04:23", .fps25))
        #expect(clip1.offsetAsTimecode()?.frameRate == .fps25)
        #expect(clip1.name == "Sync Clip 1")
        #expect(clip1.startAsTimecode() == Self.tc("10:43:05:16", .fps25))
        #expect(clip1.durationAsTimecode() == Self.tc("00:00:01:24", .fps25))
        #expect(clip1.durationAsTimecode()?.frameRate == .fps25)
        
        // `sync-clip` `sync-source`s
        
        #expect(clip1.syncSources.count == 1)
        let clip1SyncSource = try #require(clip1.syncSources.first)
        
        #expect(clip1SyncSource.audioRoleSources.count == 4)
        
        let arSource0 = try #require(clip1SyncSource.audioRoleSources[safe: 0])
        #expect(arSource0.role == .init(rawValue: "dialogue.MixL")!)
        #expect(arSource0.active)
        
        let arSource1 = try #require(clip1SyncSource.audioRoleSources[safe: 1])
        #expect(arSource1.role == .init(rawValue: "Blank")!)
        #expect(!arSource1.active)
        
        let arSource2 = try #require(clip1SyncSource.audioRoleSources[safe: 2])
        #expect(arSource2.role == .init(rawValue: "dialogue.MixR")!)
        #expect(arSource2.active)
        
        let arSource3 = try #require(clip1SyncSource.audioRoleSources[safe: 3])
        #expect(arSource3.role == .init(rawValue: "LavMic")!)
        #expect(!arSource3.active)
        
        // marker
        
        let markers = clip1.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        #expect(markers.count == 1)
        
        // FCP shows video role: "VFX.VFX-Background"
        // FCP shows audio roles: "MixL, MixR" of Dialogue
        let marker = try #require(markers.first)
        #expect(marker.name == "Marker 1")
        #expect(marker.startAsTimecode() == Self.tc("10:43:05:16", .fps25))
        let extractedMarker = await marker.element.fcpExtract()
        #expect(extractedMarker.value(forContext: .absoluteStartAsTimecode()) == Self.tc("01:01:04:23", .fps25))
        #expect(extractedMarker.value(forContext: .inheritedRoles) == [
            .inherited(.video(raw: "VFX.VFX-Background")!), // from first video asset in sync clip
            .inherited(.audio(raw: "dialogue.MixL")!), // from asset clip sync-source
            .inherited(.audio(raw: "dialogue.MixR")!) // from asset clip sync-source
        ])
    }
}

#endif
