//
//  SRT Files.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import TestingExtensions

extension TestResource {
    private static let subFolder: String = "SRT Files"
    
    enum SRTFiles {
        static let bomCrLfExtendedChars = File(name: "SRT-BOM-CRLF-ExtendedChars", ext: "srt", subFolder: subFolder)
    }
}
