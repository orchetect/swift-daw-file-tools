//
//  FinalCutPro FCPXML SyncClipRoles2.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_SyncClipRoles2: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.syncClipRoles2.data()
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
        // confirm we have the right clip
        #expect(clip1.name == "5A-1-1")
        
        let markers = clip1.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        #expect(markers.count == 1)
        
        let marker = try #require(markers.first)
        // confirm we have the right marker
        #expect(marker.name == "Marker 1")
        let extractedMarker = await marker.element.fcpExtract()
        #expect(
            extractedMarker.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:01:18:03", .fps25)
        )
        #expect(
            extractedMarker.value(forContext: .inheritedRoles) == [
                .defaulted(.video(raw: "Video")!) // from first video asset in sync clip
                // no audio role
            ]
        )
    }
}

#endif
