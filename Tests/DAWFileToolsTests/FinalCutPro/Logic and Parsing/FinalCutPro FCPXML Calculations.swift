//
//  FinalCutPro FCPXML Calculations.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_Calculations: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.basicMarkers_1HourProjectStart.data()
    } }
    
    @Test
    func start() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // root
        let fcpxmlElement = fcpxml.root.element
        #expect(fcpxmlElement.fcpStart == nil)
        
        // library
        let library = try #require(fcpxmlElement.firstChildElement(named: "library"))
        #expect(library.fcpStart == nil)
        
        // event
        let event = try #require(library.firstChildElement(named: "event"))
        #expect(event.fcpStart == nil)
        
        // project
        let project = try #require(event.firstChildElement(named: "project"))
        #expect(project.fcpStart == nil)
        
        // sequence
        let sequence = try #require(project.firstChildElement(named: "sequence"))
        #expect(sequence.fcpStart == nil)
        
        // spine
        let spine = try #require(sequence.firstChildElement(named: "spine"))
        #expect(spine.fcpStart == nil)
        
        // title
        let title = try #require(spine.firstChildElement(named: "title"))
        #expect(title.fcpStart == Fraction(1441440000, 2400000))
        #expect(title.fcpAsTitle?.startAsTimecode() == Self.tc("00:10:00:00", .fps29_97))
        
        // marker
        let marker = try #require(title.firstChildElement(named: "marker"))
        #expect(marker.fcpStart == Fraction(27248221, 7500))
        #expect(marker.fcpAsMarker?.startAsTimecode() == Self.tc("01:00:29:14", .fps29_97))
    }
    
    @Test
    func nearestStart() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // root
        let fcpxmlElement = fcpxml.root.element
        #expect(fcpxmlElement._fcpNearestStart(includingSelf: true) == nil)
        
        // library
        let library = try #require(fcpxmlElement.firstChildElement(named: "library"))
        #expect(library._fcpNearestStart(includingSelf: true) == nil)
        
        // event
        let event = try #require(library.firstChildElement(named: "event"))
        #expect(event._fcpNearestStart(includingSelf: true) == nil)
        
        // project
        let project = try #require(event.firstChildElement(named: "project"))
        #expect(project._fcpNearestStart(includingSelf: true) == nil)
        
        // sequence
        let sequence = try #require(project.firstChildElement(named: "sequence"))
        #expect(sequence._fcpNearestStart(includingSelf: true) == nil)
        
        // spine
        let spine = try #require(sequence.firstChildElement(named: "spine"))
        #expect(spine._fcpNearestStart(includingSelf: true) == nil)
        
        // title
        let title = try #require(spine.firstChildElement(named: "title"))
        #expect(title._fcpNearestStart(includingSelf: true) == Fraction(1441440000, 2400000))
        
        // marker
        let marker = try #require(title.firstChildElement(named: "marker"))
        #expect(marker._fcpNearestStart(includingSelf: true) == Fraction(27248221, 7500))
    }
    
    @Test
    func tcStart() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // root
        let fcpxmlElement = fcpxml.root.element
        #expect(fcpxmlElement.fcpTCStart == nil)
        
        // library
        let library = try #require(fcpxmlElement.firstChildElement(named: "library"))
        #expect(library.fcpTCStart == nil)
        
        // event
        let event = try #require(library.firstChildElement(named: "event"))
        #expect(event.fcpTCStart == nil)
        
        // project
        let project = try #require(event.firstChildElement(named: "project"))
        #expect(project.fcpTCStart == nil)
        
        // sequence
        let sequence = try #require(project.firstChildElement(named: "sequence"))
        #expect(sequence.fcpTCStart == Fraction(8648640000, 2400000))
        #expect(sequence.fcpAsSequence?.tcStartAsTimecode() == Self.tc("01:00:00:00", .fps29_97))
        
        // spine
        let spine = try #require(sequence.firstChildElement(named: "spine"))
        #expect(spine.fcpTCStart == nil)
        
        // title
        let title = try #require(spine.firstChildElement(named: "title"))
        #expect(title.fcpTCStart == nil)
        
        // marker
        let marker = try #require(title.firstChildElement(named: "marker"))
        #expect(marker.fcpTCStart == nil)
    }
    
    @Test
    func nearestTCStart() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // root
        let fcpxmlElement = fcpxml.root.element
        #expect(fcpxmlElement._fcpNearestTCStart(includingSelf: true) == nil)
        
        // library
        let library = try #require(fcpxmlElement.firstChildElement(named: "library"))
        #expect(library._fcpNearestTCStart(includingSelf: true) == nil)
        
        // event
        let event = try #require(library.firstChildElement(named: "event"))
        #expect(event._fcpNearestTCStart(includingSelf: true) == nil)
        
        // project
        let project = try #require(event.firstChildElement(named: "project"))
        #expect(project._fcpNearestTCStart(includingSelf: true) == nil)
        
        // sequence
        let sequence = try #require(project.firstChildElement(named: "sequence"))
        #expect(sequence._fcpNearestTCStart(includingSelf: true) == Fraction(8648640000, 2400000))
        
        // spine
        let spine = try #require(sequence.firstChildElement(named: "spine"))
        #expect(spine._fcpNearestTCStart(includingSelf: true) == Fraction(8648640000, 2400000))
        
        // title
        let title = try #require(spine.firstChildElement(named: "title"))
        #expect(title._fcpNearestTCStart(includingSelf: true) == Fraction(8648640000, 2400000))
        
        // marker
        let marker = try #require(title.firstChildElement(named: "marker"))
        #expect(marker._fcpNearestTCStart(includingSelf: true) == Fraction(8648640000, 2400000))
    }
}

#endif
