//
//  Cubase TrackArchive BasicMarkers.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Testing
import TestingExtensions
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

@Suite struct Cubase_TrackArchive_BasicMarkers {
    @Test
    func basicMarkers() async throws {
        // load file
        
        let rawData = try TestResource.CubaseTrackArchiveXMLExports.basicMarkers.data()
        
        // parse
        
        var parseMessages: [Cubase.TrackArchive.ParseMessage] = []
        let trackArchive = try Cubase.TrackArchive(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // ---- main ----
        
        // frame rate
        #expect(trackArchive.main.frameRate == .fps23_976)
        
        // start timecode
        #expect(
            trackArchive.main.startTimecode?.components
                == .init(d: 0, h: 00, m: 59, s: 59, f: 10, sf: 19)
        )
        
        // length timecode
        #expect(
            trackArchive.main.lengthTimecode?.components
                == .init(d: 0, h: 00, m: 05, s: 00, f: 00, sf: 00)
        )
        
        // TimeType - not implemented yet
        
        // bar offset
        #expect(trackArchive.main.barOffset == 0)
        
        // sample rate
        #expect(trackArchive.main.sampleRate == 48000.0)
        
        // bit depth
        #expect(trackArchive.main.bitDepth == 24)
        
        // SampleFormatSize - not implemented yet
        
        // RecordFile - not implemented yet
        
        // RecordFileType ... - not implemented yet
        
        // PanLaw - not implemented yet
        
        // VolumeMax - not implemented yet
        
        // HmtType - not implemented yet
        
        // HMTDepth
        #expect(trackArchive.main.hmtDepth == 100)
        
        // ---- tempo track ----
        
        #expect(trackArchive.tempoTrack.events.count == 3)
        
        #expect(trackArchive.tempoTrack.events[safe: 0]?.tempo == 115.0)
        #expect(trackArchive.tempoTrack.events[safe: 0]?.type == .jump)
        
        #expect(trackArchive.tempoTrack.events[safe: 1]?.tempo == 120.0)
        #expect(trackArchive.tempoTrack.events[safe: 1]?.type == .jump)
        
        #expect(trackArchive.tempoTrack.events[safe: 2]?.tempo == 155.74200439453125)
        #expect(trackArchive.tempoTrack.events[safe: 2]?.type == .jump)
        
        // ---- tracks ----
        
        #expect(trackArchive.tracks?.count == 3)
        
        // track 1 - musical mode
        
        guard case let .marker(track1) = trackArchive.tracks?[0] else { Issue.record(); return }
        #expect(track1.name == "Cues")
        
        guard case let .cycleMarker(track1event1) = track1.events[safe: 0] else { Issue.record(); return }
        #expect(track1event1.name == "Cycle Marker Name 1")
        
        #expect(
            track1event1.startTimecode.components
                == .init(d: 0, h: 01, m: 00, s: 01, f: 12, sf: 22)
        )
        // Cubase project displays 00:00:02:02.03 as the cycle marker length
        // but our calculations get 00:00:02:02.02
        #expect(
            track1event1.lengthTimecode.components
                == .init(d: 0, h: 00, m: 00, s: 02, f: 02, sf: 02)
        )
        
        // track 2 - musical mode
        
        guard case let .marker(track2) = trackArchive.tracks?[1] else { Issue.record(); return }
        #expect(track2.name == "Stems")
        
        guard case let .cycleMarker(track2event1) = track2.events[safe: 0] else { Issue.record(); return }
        #expect(track2event1.name == "Cycle Marker Name 2")
        
        #expect(
            track2event1.startTimecode.components
                == .init(d: 0, h: 01, m: 00, s: 03, f: 14, sf: 25)
        )
        // Cubase project displays 00:00:02:02.03 as the cycle marker length
        // but our calculations get 00:00:02:02.02
        #expect(
            track2event1.lengthTimecode.components
                == .init(d: 0, h: 00, m: 00, s: 02, f: 02, sf: 02)
        )
        
        // track 3 - linear mode (absolute time)
        
        guard case let .marker(track3) = trackArchive.tracks?[2] else { Issue.record(); return }
        #expect(track3.name == "TC Markers")
        
        guard case let .marker(track3event1) = track3.events[safe: 0] else { Issue.record(); return }
        #expect(track3event1.name == "Marker at One Hour")
        #expect(
            track3event1.startTimecode.components
                == .init(d: 0, h: 01, m: 00, s: 00, f: 00, sf: 00)
        )
    }
}

#endif
