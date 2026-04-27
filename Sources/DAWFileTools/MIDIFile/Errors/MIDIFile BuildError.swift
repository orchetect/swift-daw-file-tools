//
//  MIDIFile BuildError.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if MIDIFile

import Foundation
import SwiftMIDIFile

extension MusicalMIDI1File {
    /// Cubase track archive XML parsing error.
    public enum BuildError: Error {
        case general(String)
    }
}

#endif
