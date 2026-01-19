//
//  Cubase TrackArchive XML Exports.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import TestingExtensions

extension TestResource {
    private static let subFolder: String = "Cubase TrackArchive XML Exports"
    
    enum CubaseTrackArchiveXMLExports {
        static let basicMarkers = File(name: "BasicMarkers", ext: "xml", subFolder: subFolder)
        
        static let musicalAndLinearTest = File(name: "MusicalAndLinearTest", ext: "xml", subFolder: subFolder)
        
        static let roundingTest = File(name: "RoundingTest", ext: "xml", subFolder: subFolder)
    }
}
