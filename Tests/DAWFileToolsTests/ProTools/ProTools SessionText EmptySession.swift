//
//  ProTools SessionText EmptySession.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_EmptySession {
    @Test
    func sessionText_EmptySession() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.emptySession_23_976fps_DefaultExportOptions_PT2020_3.data()
        
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
        
        #expect(sessionInfo.main.name == "SessionText_EmptySession")
        #expect(sessionInfo.main.sampleRate == 48000.0)
        #expect(sessionInfo.main.bitDepth == "24-bit")
        #expect(try sessionInfo.main.startTimecode == ProTools.formTimecode(.init(h: 0, m: 59, s: 55, f: 00), at: .fps23_976))
        #expect(sessionInfo.main.frameRate == .fps23_976)
        #expect(sessionInfo.main.audioTrackCount == 0)
        #expect(sessionInfo.main.audioClipCount == 0)
        #expect(sessionInfo.main.audioFileCount == 0)
        
        // files - online
        
        #expect(sessionInfo.onlineFiles == [])
        
        // files - offline
        
        #expect(sessionInfo.offlineFiles == [])
        
        // clips - online
        
        #expect(sessionInfo.onlineClips == nil) // missing section
        
        // clips - offline
        
        #expect(sessionInfo.offlineClips == nil) // missing section
        
        // plug-ins
        
        #expect(sessionInfo.plugins == [])
        
        // tracks
        
        #expect(sessionInfo.tracks == [])
        
        // markers
        
        #expect(sessionInfo.markers == [])
        
        // orphan data
        
        #expect(sessionInfo.orphanData == nil) // none
    }
}
