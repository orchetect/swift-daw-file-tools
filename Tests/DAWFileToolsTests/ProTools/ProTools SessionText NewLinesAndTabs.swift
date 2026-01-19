//
//  ProTools SessionText NewLinesAndTabs.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_NewLinesAndTabs {
    @Test
    func sessionText_NewLinesAndTabs() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.newLinesAndTabs_DefaultExportOptions_PT2023_6.data()
        
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
        
        #expect(sessionInfo.main.name == "SessionText_NewLinesAndTabs")
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
        
        let markers = try #require(sessionInfo.markers)
        
        #expect(markers.count == 12)
        
        let marker1 = markers[0]
        #expect(marker1.number == 1)
        #expect(marker1.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 00, f: 00), at: .fps23_976)))
        #expect(marker1.timeReference == .samples(240240))
        #expect(marker1.name == "Marker Name\nWith New Line")
        #expect(marker1.comment == nil)
        
        let marker2 = markers[1]
        #expect(marker2.number == 2)
        #expect(marker2.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 01, f: 00), at: .fps23_976)))
        #expect(marker2.timeReference == .samples(288288))
        #expect(marker2.name == "Normal Marker Name")
        #expect(marker2.comment == "Comment Here\nWith New Line")
        
        let marker3 = markers[2]
        #expect(marker3.number == 3)
        #expect(marker3.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 02, f: 00), at: .fps23_976)))
        #expect(marker3.timeReference == .samples(336336))
        #expect(marker3.name == "Marker Name Again\nWith New Line Again")
        #expect(marker3.comment == "Comment Here Again\nWith New Line Again")
        
        let marker4 = markers[3]
        #expect(marker4.number == 4)
        #expect(marker4.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 03, f: 00), at: .fps23_976)))
        #expect(marker4.timeReference == .samples(384384))
        #expect(marker4.name == "Normal Marker Name Again")
        #expect(marker4.comment == nil)
        
        let marker5 = markers[4]
        #expect(marker5.number == 5)
        #expect(marker5.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 04, f: 00), at: .fps23_976)))
        #expect(marker5.timeReference == .samples(432432))
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker5.name == "Marker Name\tWith Tab")
        }
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker5.comment == nil)
        }
        
        let marker6 = markers[5]
        #expect(marker6.number == 6)
        #expect(marker6.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 05, f: 00), at: .fps23_976)))
        #expect(marker6.timeReference == .samples(480480))
        #expect(marker6.name == "Normal Marker Name")
        #expect(marker6.comment == "Comments Here\tWith Tab")
        
        let marker7 = markers[6]
        #expect(marker7.number == 7)
        #expect(marker7.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 06, f: 00), at: .fps23_976)))
        #expect(marker7.timeReference == .samples(528528))
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker7.name == "Marker Name\tWith Tab")
        }
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker7.comment == "Comments Here\tWith Tab")
        }
        
        let marker8 = markers[7]
        #expect(marker8.number == 8)
        #expect(marker8.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 07, f: 00), at: .fps23_976)))
        #expect(marker8.timeReference == .samples(576576))
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker8.name == "Marker Name\tWith Tab\tAnd Another Tab")
        }
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker8.comment == nil)
        }
        
        let marker9 = markers[8]
        #expect(marker9.number == 9)
        #expect(marker9.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 08, f: 00), at: .fps23_976)))
        #expect(marker9.timeReference == .samples(624624))
        #expect(marker9.name == "Normal Marker Name")
        #expect(marker9.comment == "Comment Here\tWith Tab\tAnd Another Tab")
        
        let marker10 = markers[9]
        #expect(marker10.number == 10)
        #expect(marker10.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 09, f: 00), at: .fps23_976)))
        #expect(marker10.timeReference == .samples(672672))
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker10.name == "Marker Name\tWith Tab\tAnd Another Tab")
        }
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker10.comment == "Comment Here\tWith Tab\tAnd Another Tab")
        }
        
        let marker11 = markers[10]
        #expect(marker11.number == 11)
        #expect(marker11.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 10, f: 00), at: .fps23_976)))
        #expect(marker11.timeReference == .samples(720720))
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker11.name == "Marker Name\tWith Tab\nAnd Newline")
        }
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker11.comment == nil)
        }
        
        let marker12 = markers[11]
        #expect(marker12.number == 12)
        #expect(marker12.location == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 11, f: 00), at: .fps23_976)))
        #expect(marker12.timeReference == .samples(768768))
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker12.name == "Normal Marker Name")
        }
        withKnownIssue("No reasonable way to parse tabs in this manner.") {
            #expect(marker12.comment == "Comment Here\tWith Tab\nAnd Newline")
        }
        
        // orphan data
        
        #expect(sessionInfo.orphanData == nil) // none
    }
}
