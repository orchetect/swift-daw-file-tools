//
//  Cubase TrackArchive init converting.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing

@Suite struct Cubase_TrackArchive_ConvertingDAWMarkers {
    @Test
    func convertingDAWMarkers_IncludeComments_NoComments() async throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: nil)
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        #expect(buildMessages.isEmpty)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        #expect(trackArchive.main.startTimecode == Timecode(.zero, at: .fps24))
        #expect(trackArchive.main.frameRate == .fps24)
        
        // markers
        
        let tracks = try #require(trackArchive.tracks)
        #expect(tracks.count == 1)
        
        guard case let .marker(track1) = tracks[0] else { Issue.record(); return }
        #expect(track1.name == "Markers")
        
        #expect(track1.events.count == 2)
        
        let marker1 = track1.events[0]
        #expect(marker1.name == "Marker1")
        #expect(marker1.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker1.startTimecode == Timecode(.components(f: 12), at: .fps24))
        
        let marker2 = track1.events[1]
        #expect(marker2.name == "Marker2")
        #expect(marker2.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker2.startTimecode == Timecode(.components(s: 1), at: .fps24))
    }
    
    @Test
    func convertingDAWMarkers_IncludeComments_WithComments() async throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: "Comment2")
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        #expect(buildMessages.isEmpty)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        #expect(trackArchive.main.startTimecode == Timecode(.zero, at: .fps24))
        #expect(trackArchive.main.frameRate == .fps24)
        
        // markers
        
        let tracks = try #require(trackArchive.tracks)
        #expect(tracks.count == 1)
        
        guard case let .marker(track1) = tracks[0] else { Issue.record(); return }
        #expect(track1.name == "Markers")
        
        #expect(track1.events.count == 2)
        
        let marker1 = track1.events[0]
        #expect(marker1.name == "Marker1")
        #expect(marker1.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker1.startTimecode == Timecode(.components(f: 12), at: .fps24))
        
        let marker2 = track1.events[1]
        #expect(marker2.name == "Marker2 - Comment2")
        #expect(marker2.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker2.startTimecode == Timecode(.components(s: 1), at: .fps24))
    }
    
    @Test
    func convertingDAWMarkers_IncludeComments_SeparateCommentsTrack_VariedComments() async throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: "Comment2")
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            separateCommentsTrack: true,
            buildMessages: &buildMessages
        )
        
        // build messages
        #expect(buildMessages.isEmpty)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        #expect(trackArchive.main.startTimecode == Timecode(.zero, at: .fps24))
        #expect(trackArchive.main.frameRate == .fps24)
        
        // markers
        
        let tracks = try #require(trackArchive.tracks)
        #expect(tracks.count == 2)
        
        // track 1 (markers)
        
        do {
            guard case let .marker(track1) = tracks[0] else { Issue.record(); return }
            #expect(track1.name == "Markers")
            
            #expect(track1.events.count == 2)
            
            let marker1 = track1.events[0]
            #expect(marker1.name == "Marker1")
            #expect(marker1.startRealTime == nil) // not stored since we're computing based on start timecode
            #expect(try marker1.startTimecode == Timecode(.components(f: 12), at: .fps24))
            
            let marker2 = track1.events[1]
            #expect(marker2.name == "Marker2")
            #expect(marker2.startRealTime == nil) // not stored since we're computing based on start timecode
            #expect(try marker2.startTimecode == Timecode(.components(s: 1), at: .fps24))
        }
        
        // track 2 (comments)
        
        do {
            guard case let .marker(track2) = tracks[1] else { Issue.record(); return }
            #expect(track2.name == "Comments")
            
            #expect(track2.events.count == 1)
            
            let marker = track2.events[0]
            #expect(marker.name == "Comment2")
            #expect(marker.startRealTime == nil) // not stored since we're computing based on start timecode
            #expect(try marker.startTimecode == Timecode(.components(s: 1), at: .fps24))
        }
    }
    
    @Test
    func convertingDAWMarkers_DoNotIncludeComments_WithComments() async throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: "Comment2")
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: false,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        #expect(buildMessages.isEmpty)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        #expect(trackArchive.main.startTimecode == Timecode(.zero, at: .fps24))
        #expect(trackArchive.main.frameRate == .fps24)
        
        // markers
        
        let tracks = try #require(trackArchive.tracks)
        #expect(tracks.count == 1)
        
        guard case let .marker(track1) = tracks[0] else { Issue.record(); return }
        #expect(track1.name == "Markers")
        
        #expect(track1.events.count == 2)
        
        let marker1 = track1.events[0]
        #expect(marker1.name == "Marker1")
        #expect(marker1.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker1.startTimecode == Timecode(.components(f: 12), at: .fps24))
        
        let marker2 = track1.events[1]
        #expect(marker2.name == "Marker2")
        #expect(marker2.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker2.startTimecode == Timecode(.components(s: 1), at: .fps24))
    }
    
    @Test
    func convertingDAWMarkers_TimecodeStorage() async throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .timecodeString(absolute: "00:00:00:12"), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .timecodeString(absolute: "00:00:01:00"), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: nil)
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        #expect(buildMessages.isEmpty)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        #expect(trackArchive.main.startTimecode == Timecode(.zero, at: .fps24))
        #expect(trackArchive.main.frameRate == .fps24)
        
        // markers
        
        let tracks = try #require(trackArchive.tracks)
        #expect(tracks.count == 1)
        
        guard case let .marker(track1) = tracks[0] else { Issue.record(); return }
        #expect(track1.name == "Markers")
        
        #expect(track1.events.count == 2)
        
        let marker1 = track1.events[0]
        #expect(marker1.name == "Marker1")
        #expect(marker1.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker1.startTimecode == Timecode(.components(f: 12), at: .fps24))
        
        let marker2 = track1.events[1]
        #expect(marker2.name == "Marker2")
        #expect(marker2.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker2.startTimecode == Timecode(.components(s: 1), at: .fps24))
    }
    
    @Test
    func convertingDAWMarkers_NonZeroTimelineStart() async throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .timecodeString(absolute: "00:00:00:12"), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .timecodeString(absolute: "00:00:01:00"), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: nil)
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: try Timecode(.components(h: 23), at: .fps24),
            includeComments: true,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        #expect(buildMessages.isEmpty)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        #expect(try trackArchive.main.startTimecode == Timecode(.components(h: 23), at: .fps24))
        #expect(trackArchive.main.frameRate == .fps24)
        
        // markers
        
        let tracks = try #require(trackArchive.tracks)
        #expect(tracks.count == 1)
        
        guard case let .marker(track1) = tracks[0] else { Issue.record(); return }
        #expect(track1.name == "Markers")
        
        #expect(track1.events.count == 2)
        
        let marker1 = track1.events[0]
        #expect(marker1.name == "Marker1")
        #expect(marker1.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker1.startTimecode == Timecode(.components(f: 12), at: .fps24))
        
        let marker2 = track1.events[1]
        #expect(marker2.name == "Marker2")
        #expect(marker2.startRealTime == nil) // not stored since we're computing based on start timecode
        #expect(try marker2.startTimecode == Timecode(.components(s: 1), at: .fps24))
    }
}

#endif
