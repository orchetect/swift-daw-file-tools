//
//  ProTools SessionText FPPFinal.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_FPPFinal {
    @Test
    func sessionText_FPPFinal() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.fppFinal_23_976fps_DefaultExportOptions_PT2020_3.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // main header
        
        #expect(
            sessionInfo.main.name
                == "FPP Edit 15 A1.4 A2.2 A3.2 A4.2 A5.2 A6.2 A7.2 A8.2 A9.2 Intl.1"
        )
        #expect(sessionInfo.main.sampleRate == 48000.0)
        #expect(sessionInfo.main.bitDepth == "24-bit")
        #expect(try sessionInfo.main.startTimecode == ProTools.formTimecode(.init(h: 0, m: 59, s: 55, f: 00), at: .fps23_976))
        #expect(sessionInfo.main.frameRate == .fps23_976)
        #expect(sessionInfo.main.audioTrackCount == 51)
        #expect(sessionInfo.main.audioClipCount == 765)
        #expect(sessionInfo.main.audioFileCount == 142)
        
        // files - online
        
        #expect(sessionInfo.onlineFiles?.count == 142)
        
        // files - offline
        
        #expect(sessionInfo.offlineFiles == [])
        
        // clips - online
        
        #expect(sessionInfo.onlineClips?.count == 753)
        
        // clips - offline
        
        #expect(sessionInfo.offlineClips == nil) // missing section
        
        // plug-ins
        
        #expect(sessionInfo.plugins?.count == 7)
        
        // tracks
        
        let tracks = try #require(sessionInfo.tracks)
        let firstTrack = try #require(tracks.first)
        #expect(firstTrack.name == "DLG")
        #expect(firstTrack.state == [.muted])
        #expect(firstTrack.clips.count == 65)
        let lastTrack = try #require(tracks.last)
        #expect(lastTrack.name == "Master Bounce (Stereo)")
        #expect(lastTrack.state == [.hidden, .inactive, .soloSafe])
        #expect(lastTrack.clips.count == 0)
        
        // markers
        
        #expect(sessionInfo.markers?.count == 294)
        
        // orphan data
        
        #expect(sessionInfo.orphanData == nil) // none
    }
}
