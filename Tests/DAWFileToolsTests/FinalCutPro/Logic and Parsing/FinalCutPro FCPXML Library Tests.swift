//
//  FinalCutPro FCPXML Library Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing

@Suite struct FinalCutPro_FCPXML_Library: FCPXMLUtilities {
    @Test
    func location() async throws {
        let url = try #require(URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/"))
        let library = FinalCutPro.FCPXML.Library(location: url)
        
        #expect(library.location == url)
    }
    
    @Test
    func name() async throws {
        let url = try #require(URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/"))
        let library = FinalCutPro.FCPXML.Library(location: url)
        
        #expect(library.name == "MyLibrary")
    }
}

#endif
