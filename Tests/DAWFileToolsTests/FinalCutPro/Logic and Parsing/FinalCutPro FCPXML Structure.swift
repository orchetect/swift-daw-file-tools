//
//  FinalCutPro FCPXML Structure.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Testing
import TestingExtensions
/* @testable */ import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

@Suite struct FinalCutPro_FCPXML_Structure: FCPXMLUtilities {
    /// Ensure that elements that can appear in various locations in the XML hierarchy are all found.
    @Test
    func parse() async throws {
        // load file
        
        let rawData = try TestResource.FCPXMLExports.structure.data()
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // events
        
        let events = Set(fcpxml.allEvents().map(\.name))
        #expect(events == ["Test Event", "Test Event 2"])
                
        // projects
        
        let projects = Set(fcpxml.allProjects().map(\.name))
        #expect(projects == ["Test Project", "Test Project 2", "Test Project 3"])
        
        // TODO: it may be possible for story elements (sequence, clips, etc.) to be in the root `fcpxml` element
        // the docs say that they can be there as browser elements
        // test parsing them? might need a new method to get them specifically like `FinalCutPro.FCPXML.parseStoryElementsInRoot()`
    }
}

#endif
