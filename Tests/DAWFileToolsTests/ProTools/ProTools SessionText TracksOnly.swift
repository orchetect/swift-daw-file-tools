//
//  ProTools SessionText TracksOnly.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_TracksOnly {
    @Test
    func sessionText_TracksOnly() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.tracksOnly_OnlyTrackEDLs_PT2023_6.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(
            fileContent: rawData,
            // no time values present in the file but supply a time format anyway to suppress the
            // format auto-detect error
            timeValueFormat: .timecode,
            messages: &parseMessages
        )
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // main header
        
        #expect(sessionInfo.main.name == "SessionText_TracksOnly")
        #expect(sessionInfo.main.sampleRate == 48000.0)
        #expect(sessionInfo.main.bitDepth == "24-bit")
        #expect(try sessionInfo.main.startTimecode == ProTools.formTimecode(.init(h: 0, m: 59, s: 50, f: 00), at: .fps24))
        #expect(sessionInfo.main.frameRate == .fps24)
        #expect(sessionInfo.main.audioTrackCount == 163)
        #expect(sessionInfo.main.audioClipCount == 1541)
        #expect(sessionInfo.main.audioFileCount == 247)
        
        // files - online
        
        #expect(sessionInfo.onlineFiles == nil) // missing section
        
        // files - offline
        
        #expect(sessionInfo.offlineFiles == nil) // missing section
        
        // clips - online
        
        #expect(sessionInfo.onlineClips == nil) // missing section
        
        // clips - offline
        
        #expect(sessionInfo.offlineClips == nil) // missing section
        
        // plug-ins
        
        #expect(sessionInfo.plugins == nil) // missing section
        
        // tracks
        
        let tracks = try #require(sessionInfo.tracks)
        #expect(tracks.count == 7)
        
        let track1 = try #require(tracks[safe: 0])
        #expect(track1.name == "Audio 1")
        #expect(track1.comments == "")
        #expect(track1.userDelay == 0)
        #expect(track1.state == [])
        #expect(track1.plugins == [])
        
        #expect(track1.clips.count == 2)
        
        // -- track 1 clip 1
        let track1clip1 = try #require(track1.clips[safe: 0])
        #expect(track1clip1.channel == 1)
        #expect(track1clip1.event == 1)
        #expect(track1clip1.name == "Warm Day in the City")
        #expect(
            track1clip1.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 15, f: 06), at: .fps24))
        )
        #expect(
            track1clip1.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 01, s: 05, f: 13), at: .fps24))
        )
        #expect(
            track1clip1.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 50, f: 07), at: .fps24))
        )
        #expect(track1clip1.state == .unmuted)
        
        // -- track 1 clip 2
        let track1clip2 = try #require(track1.clips[safe: 1])
        #expect(track1clip2.channel == 1)
        #expect(track1clip2.event == 2)
        #expect(track1clip2.name == "Happy Go Lucky")
        #expect(
            track1clip2.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 01, s: 05, f: 13), at: .fps24))
        )
        #expect(
            track1clip2.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 01, s: 57, f: 23), at: .fps24))
        )
        #expect(
            track1clip2.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 52, f: 09), at: .fps24))
        )
        #expect(track1clip2.state == .unmuted)
        
        let track2 = try #require(tracks[safe: 1])
        #expect(track2.name == "Audio 2")
        #expect(track2.clips.count == 0)
        
        let track3 = try #require(tracks[safe: 2])
        #expect(track3.name == "Audio 3")
        #expect(track3.clips.count == 0)
        
        let track4 = try #require(tracks[safe: 3])
        #expect(track4.name == "Audio 4")
        #expect(track4.clips.count == 0)
        
        let track5 = try #require(tracks[safe: 4])
        #expect(track5.name == "Audio 5")
        #expect(track5.clips.count == 0)
        
        let track6 = try #require(tracks[safe: 5])
        #expect(track6.name == "Audio 6")
        #expect(track6.clips.count == 0)
        
        let track7 = try #require(tracks[safe: 6])
        #expect(track7.name == "Audio 7")
        #expect(track7.clips.count == 0)
        
        // markers
        
        #expect(sessionInfo.markers == nil) // missing section
        
        // orphan data
        
        #expect(sessionInfo.orphanData == nil) // none
    }
}
