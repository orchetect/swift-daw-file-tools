//
//  Cubase TrackArchive Helper Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import Testing
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

@Suite struct Cubase_Helper_Tests {
    @Test
    func collection_XMLElement_FilterAttribute() async throws {
        // prep
        
        let nodes = [
            try XMLElement(xmlString: "<obj class='classA' name='name1'/>"),
            try XMLElement(xmlString: "<obj class='classA' name='name2'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name3'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name4'/>")
        ]
        
        // test
        
        let filteredA = nodes.filter(whereNameAttributeValue: "name2").zeroIndexed
        #expect(filteredA[0] == nodes[1])
        
        let filteredB = nodes.filter(whereClassAttributeValue: "classA").zeroIndexed
        #expect(filteredB[0] == nodes[0])
        #expect(filteredB[1] == nodes[1])
    }
    
    @Test
    func collection_XMLElement_FirstAttribute() async throws {
        // prep
        
        let nodes = [
            try XMLElement(xmlString: "<obj class='classA' name='name1'/>"),
            try XMLElement(xmlString: "<obj class='classA' name='name2'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name3'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name4'/>")
        ]
        
        // test
        
        let firstA = nodes.first(whereNameAttributeValue: "name2")
        #expect(firstA == nodes[1])
        
        let firstB = nodes.first(whereClassAttributeValue: "classA")
        #expect(firstB == nodes[0])
    }
}

#endif
