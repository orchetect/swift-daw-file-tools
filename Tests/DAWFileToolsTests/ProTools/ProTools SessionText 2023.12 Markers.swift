//
//  ProTools SessionText 2023.12 Markers.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_2023_12_Markers {
    @Test
    func sessionText() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.markerRulersAndTrackMarkers_PT2023_12.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // main header
        
        #expect(sessionInfo.main.name == "Test")
        #expect(sessionInfo.main.sampleRate == 48000.0)
        #expect(sessionInfo.main.bitDepth == "24-bit")
        #expect(try sessionInfo.main.startTimecode == ProTools.formTimecode(.init(h: 0, m: 59, s: 50, f: 00), at: .fps24))
        #expect(sessionInfo.main.frameRate == .fps24)
        #expect(sessionInfo.main.audioTrackCount == 2)
        #expect(sessionInfo.main.audioClipCount ==  0)
        #expect(sessionInfo.main.audioFileCount ==  0)
        
        // markers
        
        let markers = try #require(sessionInfo.markers)
        #expect(markers.count == 7)
        
        #expect(
            markers[safe: 0]
            == ProTools.SessionInfo.Marker(
                number: 1,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 00, f: 00), at: .fps24)),
                timeReference: .samples(480000),
                name: "Marker 1",
                trackName: "Markers",
                trackType: .ruler,
                comment: nil
            )
        )
        
        #expect(
            markers[safe: 1]
            == ProTools.SessionInfo.Marker(
                number: 2,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 01, f: 00), at: .fps24)),
                timeReference: .samples(528000),
                name: "Marker 2",
                trackName: "Markers 2",
                trackType: .ruler,
                comment: "Some comments"
            )
        )
        
        #expect(
            markers[safe: 2]
            == ProTools.SessionInfo.Marker(
                number: 3,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 02, f: 00), at: .fps24)),
                timeReference: .samples(576000),
                name: "Marker 3",
                trackName: "Markers 3",
                trackType: .ruler,
                comment: nil
            )
        )
        
        #expect(
            markers[safe: 3]
            == ProTools.SessionInfo.Marker(
                number: 4,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 03, f: 00), at: .fps24)),
                timeReference: .samples(624000),
                name: "Marker 4",
                trackName: "Markers 4",
                trackType: .ruler,
                comment: nil
            )
        )
        
        #expect(
            markers[safe: 4]
            == ProTools.SessionInfo.Marker(
                number: 5,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 04, f: 00), at: .fps24)),
                timeReference: .samples(672000),
                name: "Marker 5",
                trackName: "Markers 5",
                trackType: .ruler,
                comment: nil
            )
        )
        
        #expect(
            markers[safe: 5]
            == ProTools.SessionInfo.Marker(
                number: 6,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 05, f: 00), at: .fps24)),
                timeReference: .samples(720000),
                name: "Marker 6",
                trackName: "Audio 1",
                trackType: .track,
                comment: "More comments"
            )
        )
        
        #expect(
            markers[safe: 6]
            == ProTools.SessionInfo.Marker(
                number: 7,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 06, f: 00), at: .fps24)),
                timeReference: .samples(768000),
                name: "Marker 7",
                trackName: "Audio 2",
                trackType: .track,
                comment: nil
            )
        )
        
        // orphan data
        
        #expect(sessionInfo.orphanData == nil) // none
    }
    
    @Test
    func dawMarkerTrackConversion() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.markerRulersAndTrackMarkers_PT2023_12.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        let frameRate = try #require(sessionInfo.main.frameRate)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // markers
        
        let dawMarkerTracks = try #require(
            sessionInfo.markers?.convertToDAWMarkers(originalFrameRate: frameRate)
        )
        #expect(dawMarkerTracks.count == 7)
        
        // spot check a few, we won't check them all
        
        let dawMarkerTrack1 = try #require(dawMarkerTracks[safe: 0])
        #expect(dawMarkerTrack1.name == "Markers")
        #expect(dawMarkerTrack1.trackType == .ruler)
        #expect(dawMarkerTrack1.markers.count == 1)
        let marker1 = try #require(dawMarkerTrack1.markers.first)
        #expect(marker1.name == "Marker 1")
        #expect(
            marker1.timeStorage
            == .init(value: .timecodeString(absolute: "01:00:00:00"),
                     frameRate: .fps24,
                     base: .max100SubFrames)
        )
        
        let dawMarkerTrack2 = try #require(dawMarkerTracks[safe: 1])
        #expect(dawMarkerTrack2.name == "Markers 2")
        #expect(dawMarkerTrack2.trackType == .ruler)
        #expect(dawMarkerTrack2.markers.count == 1)
        let marker2 = try #require(dawMarkerTrack2.markers.first)
        #expect(marker2.name == "Marker 2")
        #expect(
            marker2.timeStorage
            == .init(value: .timecodeString(absolute: "01:00:01:00"),
                     frameRate: .fps24,
                     base: .max100SubFrames)
        )
        
        let dawMarkerTrack6 = try #require(dawMarkerTracks[safe: 5])
        #expect(dawMarkerTrack6.name == "Audio 1")
        #expect(dawMarkerTrack6.trackType == .track)
        #expect(dawMarkerTrack6.markers.count == 1)
        let marker6 = try #require(dawMarkerTrack6.markers.first)
        #expect(marker6.name == "Marker 6")
        #expect(
            marker6.timeStorage
            == .init(value: .timecodeString(absolute: "01:00:05:00"),
                     frameRate: .fps24,
                     base: .max100SubFrames)
        )
    }
}
