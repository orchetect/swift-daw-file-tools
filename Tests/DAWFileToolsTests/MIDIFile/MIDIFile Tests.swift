//
//  MIDIFile Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2026 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import Foundation
import SwiftMIDIFile
import SwiftTimecodeCore
import Testing

@Suite
struct MIDIFile_Tests {
    /// Test text encoding modes.
    @Test
    func encodingMode() throws {
        func storage(_ timecodeString: String) -> DAWMarker.Storage {
            DAWMarker.Storage(
                value: .timecodeString(absolute: timecodeString),
                frameRate: .fps30,
                base: .max100SubFrames
            )
        }

        let markers: [DAWMarker] = [
            DAWMarker(storage: storage("00:00:00:00"), name: "ASCII Marker", comment: nil),
            DAWMarker(storage: storage("00:00:00:00"), name: "Extended © ASCII", comment: nil),
            DAWMarker(storage: storage("00:00:01:00"), name: "Emoji 😀", comment: nil),
            DAWMarker(storage: storage("00:00:02:00"), name: "请请让我知道", comment: nil)
        ]

        func midiFileEvents(encoding: MIDIFileEvent.Text.Encoding) throws -> [MIDIFileEvent.Text] {
            let midiFile = try MusicalMIDI1File(
                converting: markers,
                tempo: 120.0,
                startTimecode: Timecode(.zero, at: .fps24),
                includeComments: true,
                trackName: nil,
                encoding: encoding
            )
            
            #expect(midiFile.tracks.count == 1)
            let track = try #require(midiFile.tracks.first)
            
            let textEvents: [MIDIFileEvent.Text] = track.events
                .map(\.event)
                .compactMap {
                    guard case let .text(text) = $0 else { return nil }
                    return text
                }
            
            return textEvents
        }
        
        // strict ascii
        do {
            let textEvents = try midiFileEvents(encoding: .strictASCII)
            try #require(textEvents.count == markers.count)
            #expect(textEvents[0].text == "ASCII Marker")
            #expect(textEvents[1].text == "Extended (C) ASCII")
            #expect(textEvents[2].text == "Emoji ?")
            #expect(textEvents[3].text == "??????")
        }
        
        // extended ascii
        do {
            let textEvents = try midiFileEvents(encoding: .extendedASCII)
            try #require(textEvents.count == markers.count)
            #expect(textEvents[0].text == "ASCII Marker")
            #expect(textEvents[1].text == "Extended © ASCII")
            #expect(textEvents[2].text == "Emoji ?")
            #expect(textEvents[3].text == "??????")
        }
        
        // allow UTF8
        do {
            let textEvents = try midiFileEvents(encoding: .allowUTF8)
            try #require(textEvents.count == markers.count)
            #expect(textEvents[0].text == "ASCII Marker")
            #expect(textEvents[1].text == "Extended © ASCII")
            #expect(textEvents[2].text == "Emoji 😀")
            #expect(textEvents[3].text == "请请让我知道")
        }
        
    }

    @Test
    func noTrackName() throws {
        let midiFile = try MusicalMIDI1File(
            converting: [],
            tempo: 120.0,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            trackName: nil
        )
        
        #expect(midiFile.tracks.count == 1)
        let track = try #require(midiFile.tracks.first)
        
        let textEvents: [MIDIFileEvent.Text] = track.events
            .map(\.event)
            .compactMap {
                guard case let .text(text) = $0 else { return nil }
                return text
            }
        
        #expect(textEvents.isEmpty)
    }
    
    @Test
    func withTrackName() throws {
        let midiFile = try MusicalMIDI1File(
            converting: [],
            tempo: 120.0,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            trackName: "Track Name"
        )
        
        #expect(midiFile.tracks.count == 1)
        let track = try #require(midiFile.tracks.first)
        
        let textEvents: [MIDIFileEvent.Text] = track.events
            .map(\.event)
            .compactMap {
                guard case let .text(text) = $0 else { return nil }
                return text
            }
        
        try #require(textEvents.count == 1)
        
        #expect(textEvents[0].text == "Track Name")
    }
    
    // TODO: add MIDI file generation tests
}
