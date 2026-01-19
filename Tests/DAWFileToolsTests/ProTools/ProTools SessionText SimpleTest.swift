//
//  ProTools SessionText SimpleTest.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_SimpleTest {
    @Test
    func sessionText_SimpleTest() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.simpleTest_23_976fps_DefaultExportOptions_PT2020_3.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // main header
        
        #expect(sessionInfo.main.name == "SessionText_SimpleTest")
        #expect(sessionInfo.main.sampleRate == 48000.0)
        #expect(sessionInfo.main.bitDepth == "24-bit")
        #expect(try sessionInfo.main.startTimecode == ProTools.formTimecode(.init(h: 0, m: 59, s: 55, f: 00), at: .fps23_976))
        #expect(sessionInfo.main.frameRate == .fps23_976)
        #expect(sessionInfo.main.audioTrackCount == 1)
        #expect(sessionInfo.main.audioClipCount == 1)
        #expect(sessionInfo.main.audioFileCount == 1)
        
        // files - online
        
        #expect(sessionInfo.onlineFiles?.count == 1)
        
        let file1 = sessionInfo.onlineFiles?.first
        
        #expect(file1?.filename == "Audio 1_01.wav")
        #expect(file1?.path == "Macintosh HD:Users:stef:Desktop:SessionText_SimpleTest:Audio Files:")
        
        // files - offline
        
        #expect(sessionInfo.offlineFiles == [])
        
        // clips - online
        
        let onlineClips = try #require(sessionInfo.onlineClips)
        #expect(onlineClips.count == 1)
        
        let clip1 = try #require(onlineClips.first)
        #expect(clip1.name == "Audio 1_01")
        #expect(clip1.sourceFile == "Audio 1_01.wav")
        #expect(clip1.channel == nil)
        
        // clips - offline
        
        #expect(sessionInfo.offlineClips == nil) // missing section
        
        // plug-ins
        
        #expect(sessionInfo.plugins == [])
        
        // tracks
        
        let tracks = try #require(sessionInfo.tracks)
        #expect(tracks.count == 1)
        
        let track1 = try #require(tracks.first)
        #expect(track1.name == "Audio 1")
        #expect(track1.comments == "")
        #expect(track1.userDelay == 0)
        #expect(track1.state == [])
        #expect(track1.plugins == [])
        
        #expect(track1.clips.count == 1)
        
        let track1clip1 = try #require(track1.clips.first)
        #expect(track1clip1.channel == 1)
        #expect(track1clip1.event == 1)
        #expect(track1clip1.name == "Audio 1_01")
        #expect(
            track1clip1.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 00, f: 00), at: .fps23_976))
        )
        #expect(
            track1clip1.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 05, f: 00), at: .fps23_976))
        )
        #expect(
            track1clip1.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 05, f: 00), at: .fps23_976))
        )
        #expect(track1clip1.state == .unmuted)
        
        // markers
        
        #expect(sessionInfo.markers == [])
        
        // orphan data
        
        #expect(sessionInfo.orphanData == nil) // none
    }
}
