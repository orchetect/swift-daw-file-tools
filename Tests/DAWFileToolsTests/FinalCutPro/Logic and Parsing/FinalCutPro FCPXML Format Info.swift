//
//  FinalCutPro FCPXML Format Info.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_FormatInfo: FCPXMLUtilities {
    /// Ensure `format` and `tcFormat` information can be found by traversing XML parents.
    @Test
    func firstFormatAndTCFormat() async throws {
        // load file
        
        let rawData = try TestResource.FCPXMLExports.basicMarkers.data()
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // resources
        
        let resources = fcpxml.root.resources
        
        #expect(resources.childElements.count == 2)
        
        let r1 = try #require(resources.childElements[safe: 0]?.fcpAsFormat)
        #expect(r1.id == "r1")
        #expect(r1.name == "FFVideoFormat1080p2997")
        #expect(r1.frameDuration == Fraction(1001,30000))
        #expect(r1.fieldOrder == nil)
        #expect(r1.width == 1920)
        #expect(r1.height == 1080)
        #expect(r1.paspH == nil)
        #expect(r1.paspV == nil)
        #expect(r1.colorSpace == "1-1-1 (Rec. 709)")
        #expect(r1.projection == nil)
        #expect(r1.stereoscopic == nil)
        
        // format and tcFormat
        
        let xmlRoot = fcpxml.root.element
        
        // `fcpxml` element will never have `format` or `tcFormat` attributes
        do {
            let format = xmlRoot._fcpFirstFormatResourceForElementOrAncestors()
            #expect(format == nil)
            
            let tcFormat = xmlRoot._fcpTCFormatForElementOrAncestors()
            #expect(tcFormat == nil)
        }
        
        let libraryElement = try #require(xmlRoot.firstChildElement(named: "library"))
        
        // `library` element will never have `format` or `tcFormat` attributes
        do {
            let format = libraryElement._fcpFirstFormatResourceForElementOrAncestors()
            #expect(format == nil)
            
            let tcFormat = libraryElement._fcpTCFormatForElementOrAncestors()
            #expect(tcFormat == nil)
        }
        
        let xmlEvent = try #require(libraryElement.firstChildElement(named: "event"))
        
        // `event` element will never have `format` or `tcFormat` attributes
        do {
            let format = xmlEvent._fcpFirstFormatResourceForElementOrAncestors()
            #expect(format == nil)
            
            let tcFormat = xmlEvent._fcpTCFormatForElementOrAncestors()
            #expect(tcFormat == nil)
        }
        
        let xmlProject = try #require(xmlEvent.firstChildElement(named: "project"))
        
        // `project` element will never have `format` or `tcFormat` attributes
        do {
            let format = xmlProject._fcpFirstFormatResourceForElementOrAncestors()
            #expect(format == nil)
            
            let tcFormat = xmlProject._fcpTCFormatForElementOrAncestors()
            #expect(tcFormat == nil)
        }
        
        let xmlSequence = try #require(xmlProject.firstChildElement(named: "sequence"))
        
        // `sequence` element will usually have `format` and `tcFormat` attributes
        do {
            let format = try #require(xmlSequence._fcpFirstFormatResourceForElementOrAncestors())
            #expect(format == r1)
            
            let tcFormat = try #require(xmlSequence._fcpTCFormatForElementOrAncestors())
            #expect(tcFormat == .nonDropFrame)
        }
        
        let xmlSpine = try #require(xmlSequence.firstChildElement(named: "spine"))
        
        // `spine` element will usually have `format` and `tcFormat` attributes in its immediate `sequence` parent
        do {
            let format = try #require(xmlSpine._fcpFirstFormatResourceForElementOrAncestors())
            #expect(format == r1)
            
            let tcFormat = try #require(xmlSpine._fcpTCFormatForElementOrAncestors())
            #expect(tcFormat == .nonDropFrame)
        }
        
        let xmlTitle = try #require(xmlSpine.firstChildElement(named: "title"))
        
        // `title` element in this case inherits `format` and `tcFormat` attributes from its `sequence` ancestor
        do {
            let format = try #require(xmlTitle._fcpFirstFormatResourceForElementOrAncestors())
            #expect(format == r1)
            
            let tcFormat = try #require(xmlTitle._fcpTCFormatForElementOrAncestors())
            #expect(tcFormat == .nonDropFrame)
        }
        
        let xmlMarker1 = try #require(xmlTitle.firstChildElement(named: "marker"))
        
        // `marker` element in this case inherits `format` and `tcFormat` attributes from its `sequence` ancestor
        do {
            let format = try #require(xmlMarker1._fcpFirstFormatResourceForElementOrAncestors())
            #expect(format == r1)
            
            let tcFormat = try #require(xmlMarker1._fcpTCFormatForElementOrAncestors())
            #expect(tcFormat == .nonDropFrame)
        }
    }
}

#endif
