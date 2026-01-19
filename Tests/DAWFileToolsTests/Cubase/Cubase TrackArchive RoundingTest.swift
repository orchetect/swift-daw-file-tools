//
//  Cubase TrackArchive RoundingTest.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Testing
import TestingExtensions
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

@Suite struct Cubase_TrackArchive_RoundingTest {
    @Test
    func roundingTest() async throws {
        let rawData = try TestResource.CubaseTrackArchiveXMLExports.roundingTest.data()
        
        // parse
        
        var parseMessages: [Cubase.TrackArchive.ParseMessage] = []
        let trackArchive = try Cubase.TrackArchive(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.isEmpty)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // ---- tracks ----
        
        #expect(trackArchive.tracks?.count == 2)
        
        // track 1 - musical mode
        
        guard case let .marker(track1) = trackArchive.tracks?[0] else { Issue.record(); return }
        #expect(track1.events.count == 4)
        
        guard case let .marker(track1event1) = track1.events[safe: 0] else { Issue.record(); return }
        guard case let .marker(track1event2) = track1.events[safe: 1] else { Issue.record(); return }
        guard case let .marker(track1event3) = track1.events[safe: 2] else { Issue.record(); return }
        guard case let .marker(track1event4) = track1.events[safe: 3] else { Issue.record(); return }
        
        #expect(track1event1.startTimecode.stringValue(format: [.showSubFrames]) == "01:00:01:29.00") // as displayed in Cubase
        #expect(track1event2.startTimecode.stringValue(format: [.showSubFrames]) == "01:00:01:29.78") // as displayed in Cubase
        #expect(track1event3.startTimecode.stringValue(format: [.showSubFrames]) == "01:00:01:29.79") // as displayed in Cubase
        #expect(track1event4.startTimecode.stringValue(format: [.showSubFrames]) == "01:00:02:00.00") // as displayed in Cubase
        
        // track 2 - linear mode
        
        guard case let .marker(track2) = trackArchive.tracks?[1] else { Issue.record(); return }
        #expect(track2.events.count == 4)
        
        guard case let .marker(track2event1) = track2.events[safe: 0] else { Issue.record(); return }
        guard case let .marker(track2event2) = track2.events[safe: 1] else { Issue.record(); return }
        guard case let .marker(track2event3) = track2.events[safe: 2] else { Issue.record(); return }
        guard case let .marker(track2event4) = track2.events[safe: 3] else { Issue.record(); return }
        
        #expect(track2event1.startTimecode.stringValue(format: [.showSubFrames]) == "01:00:01:29.00") // as displayed in Cubase
        #expect(track2event2.startTimecode.stringValue(format: [.showSubFrames]) == "01:00:01:29.78") // as displayed in Cubase
        #expect(track2event3.startTimecode.stringValue(format: [.showSubFrames]) == "01:00:01:29.79") // as displayed in Cubase
        #expect(track2event4.startTimecode.stringValue(format: [.showSubFrames]) == "01:00:02:00.00") // as displayed in Cubase
    }
}

#endif
