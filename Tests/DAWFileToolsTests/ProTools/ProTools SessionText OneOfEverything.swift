//
//  ProTools SessionText OneOfEverything.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_OneOfEverything {
    @Test
    func sessionText_OneOfEverything() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.oneOfEverything_23_976fps_DefaultExportOptions_PT2020_3.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // main header
        
        #expect(sessionInfo.main.name == "SessionText_OneOfEverything")
        #expect(sessionInfo.main.sampleRate == 48000.0)
        #expect(sessionInfo.main.bitDepth == "24-bit")
        #expect(try sessionInfo.main.startTimecode == ProTools.formTimecode(.init(h: 0, m: 59, s: 55, f: 00), at: .fps23_976))
        #expect(sessionInfo.main.frameRate == .fps23_976)
        #expect(sessionInfo.main.audioTrackCount == 5)
        #expect(sessionInfo.main.audioClipCount == 11)
        #expect(sessionInfo.main.audioFileCount == 7)
        
        // files - online
        
        let onlineAudioFilesPath =
            "Macintosh HD:Users:user:Documents:SessionText_OneOfEverything:Audio Files:"
        
        let onlineFiles = try #require(sessionInfo.onlineFiles)
        #expect(onlineFiles.count == 6)
        
        let file1 = onlineFiles[0]
        
        #expect(file1.filename == "Unused Clip.wav")
        #expect(file1.path == onlineAudioFilesPath)
        
        let file2 = onlineFiles[1]
        
        #expect(file2.filename == "Audio 1 Clip1.wav")
        #expect(file2.path == onlineAudioFilesPath)
        
        let file3 = onlineFiles[2]
        
        #expect(file3.filename == "Audio 2 Clip1.wav")
        #expect(file3.path == onlineAudioFilesPath)
        
        let file4 = onlineFiles[3]
        
        #expect(file4.filename == "Audio 3 Clip1.wav")
        #expect(file4.path == onlineAudioFilesPath)
        
        let file5 = onlineFiles[4]
        
        #expect(file5.filename == "Audio 3 Clip2.wav")
        #expect(file5.path == onlineAudioFilesPath)
        
        let file6 = onlineFiles[5]
        
        #expect(file6.filename == "Audio 4 Clip1.wav")
        #expect(file6.path == onlineAudioFilesPath)
        
        // files - offline
        
        let offlineFiles = try #require(sessionInfo.offlineFiles)
        #expect(offlineFiles.count == 1)
        
        let file7 = offlineFiles[0]
        
        #expect(file7.filename == "Audio 5 Offline Clip1.wav")
        #expect(file7.path == "Macintosh HD:Users:user:Documents:SessionText_OneOfEverything:Audio Files:")
        
        // clips - online
        
        let onlineClips = try #require(sessionInfo.onlineClips)
        
        #expect(onlineClips.count == 9)
        
        #expect(onlineClips[0].name == "Audio 1 Clip1")
        #expect(onlineClips[0].sourceFile == "Audio 1 Clip1.wav")
        #expect(onlineClips[0].channel == nil)
        
        #expect(onlineClips[1].name == "Audio 2 Clip1")
        #expect(onlineClips[1].sourceFile == "Audio 2 Clip1.wav")
        #expect(onlineClips[1].channel == nil)
        
        #expect(onlineClips[2].name == "Audio 3 Clip1.L")
        #expect(onlineClips[2].sourceFile == "Audio 3 Clip1.wav")
        #expect(onlineClips[2].channel == "[1]")
        
        #expect(onlineClips[3].name == "Audio 3 Clip1.R")
        #expect(onlineClips[3].sourceFile == "Audio 3 Clip1.wav")
        #expect(onlineClips[3].channel == "[2]")
        
        #expect(onlineClips[4].name == "Audio 3 Clip2.L")
        #expect(onlineClips[4].sourceFile == "Audio 3 Clip2.wav")
        #expect(onlineClips[4].channel == "[1]")
        
        #expect(onlineClips[5].name == "Audio 3 Clip2.R")
        #expect(onlineClips[5].sourceFile == "Audio 3 Clip2.wav")
        #expect(onlineClips[5].channel == "[2]")
        
        #expect(onlineClips[6].name == "Audio 4 Clip1.L")
        #expect(onlineClips[6].sourceFile == "Audio 4 Clip1.wav")
        #expect(onlineClips[6].channel == "[1]")
        
        #expect(onlineClips[7].name == "Audio 4 Clip1.R")
        #expect(onlineClips[7].sourceFile == "Audio 4 Clip1.wav")
        #expect(onlineClips[7].channel == "[2]")
        
        #expect(onlineClips[8].name == "Unused Clip")
        #expect(onlineClips[8].sourceFile == "Unused Clip.wav")
        #expect(onlineClips[8].channel == nil)
        
        // clips - offline
        
        let offlineClips = try #require(sessionInfo.offlineClips)
        
        #expect(offlineClips.count == 2)
        
        #expect(offlineClips[0].name == "Audio 5 Offline Clip1.L")
        #expect(offlineClips[0].sourceFile == "Audio 5 Offline Clip1.wav")
        #expect(offlineClips[0].channel == "[1]")
        
        #expect(offlineClips[1].name == "Audio 5 Offline Clip1.R")
        #expect(offlineClips[1].sourceFile == "Audio 5 Offline Clip1.wav")
        #expect(offlineClips[1].channel == "[2]")
        
        // plug-ins
        
        let plugins = try #require(sessionInfo.plugins)
        
        #expect(plugins.count == 3)
        
        #expect(plugins[0].manufacturer == "Avid")
        #expect(plugins[0].name == "EQ3 1-Band")
        #expect(plugins[0].version == "20.3.0d163")
        #expect(plugins[0].format == "AAX Native")
        #expect(plugins[0].stems == "Mono / Mono")
        #expect(plugins[0].numberOfInstances == "2 active")
        
        #expect(plugins[1].manufacturer == "Avid")
        #expect(plugins[1].name == "EQ3 7-Band")
        #expect(plugins[1].version == "20.3.0d163")
        #expect(plugins[1].format == "AAX Native")
        #expect(plugins[1].stems == "Mono / Mono")
        #expect(plugins[1].numberOfInstances == "1 active")
        
        #expect(plugins[2].manufacturer == "Avid")
        #expect(plugins[2].name == "Trim")
        #expect(plugins[2].version == "20.3.0d163")
        #expect(plugins[2].format == "AAX Native")
        #expect(plugins[2].stems == "Mono / Mono")
        #expect(plugins[2].numberOfInstances == "1 active")
        
        // tracks
        
        let tracks = try #require(sessionInfo.tracks)
        
        #expect(tracks.count == 5)
        
        let track1 = tracks[0]
        
        #expect(track1.name == "Audio 1")
        #expect(track1.comments == "Comments here.")
        #expect(track1.userDelay == 0)
        #expect(track1.state == [])
        #expect(track1.plugins == ["EQ3 1-Band (mono)"])
        
        #expect(track1.clips.count == 1)
        
        let track1clip1 = track1.clips[0]
        #expect(track1clip1.channel == 1)
        #expect(track1clip1.event == 1)
        #expect(track1clip1.name == "Audio 1 Clip1")
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
        
        let track2 = tracks[1]
        
        #expect(track2.name == "Audio 2")
        #expect(track2.comments == "")
        #expect(track2.userDelay == 0)
        #expect(track2.state == [])
        #expect(track2.plugins == ["EQ3 7-Band (mono)", "Trim (mono)"])
        
        #expect(track2.clips.count == 1)
        
        let track2clip1 = track2.clips[0]
        #expect(track2clip1.channel == 1)
        #expect(track2clip1.event == 1)
        #expect(track2clip1.name == "Audio 2 Clip1")
        #expect(
            track2clip1.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 06, f: 15), at: .fps23_976))
        )
        #expect(
            track2clip1.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 10, f: 03), at: .fps23_976))
        )
        #expect(
            track2clip1.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 03, f: 12), at: .fps23_976))
        )
        #expect(track2clip1.state == .unmuted)
        
        let track3 = tracks[2]
        
        #expect(track3.name == "Audio 3 (Stereo)")
        #expect(track3.comments == "")
        #expect(track3.userDelay == 0)
        #expect(track3.state == [])
        #expect(track3.plugins == [])
        
        #expect(track3.clips.count == 4)
        
        let track3clip1 = track3.clips[0]
        #expect(track3clip1.channel == 1)
        #expect(track3clip1.event == 1)
        #expect(track3clip1.name == "Audio 3 Clip1.L")
        #expect(
            track3clip1.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 12, f: 18), at: .fps23_976))
        )
        #expect(
            track3clip1.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 17, f: 08), at: .fps23_976))
        )
        #expect(
            track3clip1.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 04, f: 14), at: .fps23_976))
        )
        #expect(track3clip1.state == .unmuted)
        
        let track3clip2 = track3.clips[1]
        #expect(track3clip2.channel == 1)
        #expect(track3clip2.event == 2)
        #expect(track3clip2.name == "Audio 3 Clip2.L")
        #expect(
            track3clip2.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 18, f: 17), at: .fps23_976))
        )
        #expect(
            track3clip2.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 21, f: 19), at: .fps23_976))
        )
        #expect(
            track3clip2.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 03, f: 02), at: .fps23_976))
        )
        #expect(track3clip2.state == .muted)
        
        let track3clip3 = track3.clips[2]
        #expect(track3clip3.channel == 2)
        #expect(track3clip3.event == 1)
        #expect(track3clip3.name == "Audio 3 Clip1.R")
        #expect(
            track3clip3.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 12, f: 18), at: .fps23_976))
        )
        #expect(
            track3clip3.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 17, f: 08), at: .fps23_976))
        )
        #expect(
            track3clip3.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 04, f: 14), at: .fps23_976))
        )
        #expect(track3clip3.state == .unmuted)
        
        let track3clip4 = track3.clips[3]
        #expect(track3clip4.channel == 2)
        #expect(track3clip4.event == 2)
        #expect(track3clip4.name == "Audio 3 Clip2.R")
        #expect(
            track3clip4.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 18, f: 17), at: .fps23_976))
        )
        #expect(
            track3clip4.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 21, f: 19), at: .fps23_976))
        )
        #expect(
            track3clip4.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 03, f: 02), at: .fps23_976))
        )
        #expect(track3clip4.state == .muted)
        
        let track4 = tracks[3]
        
        _ = track4
        // TODO: track 4 contains fades on a clip - may abstract in a certain way in the future
        
        let track5 = tracks[4]
        
        #expect(track5.name == "Audio 5 (Stereo)")
        #expect(track5.comments == "")
        #expect(track5.userDelay == 0)
        #expect(track5.state == [.inactive])
        #expect(track5.plugins == [])
        
        #expect(track5.clips.count == 2)
        
        let track5clip1 = track5.clips[0]
        #expect(track5clip1.channel == 1)
        #expect(track5clip1.event == 1)
        #expect(track5clip1.name == "Audio 5 Offline Clip1.L")
        #expect(
            track5clip1.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 05, f: 14), at: .fps23_976))
        )
        #expect(
            track5clip1.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 11, f: 10), at: .fps23_976))
        )
        #expect(
            track5clip1.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 05, f: 20), at: .fps23_976))
        )
        #expect(track5clip1.state == .unmuted)
        
        let track5clip2 = track5.clips[1]
        #expect(track5clip2.channel == 2)
        #expect(track5clip2.event == 1)
        #expect(track5clip2.name == "Audio 5 Offline Clip1.R")
        #expect(
            track5clip2.startTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 05, f: 14), at: .fps23_976))
        )
        #expect(
            track5clip2.endTime
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 11, f: 10), at: .fps23_976))
        )
        #expect(
            track5clip2.duration
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 05, f: 20), at: .fps23_976))
        )
        #expect(track5clip2.state == .unmuted)
        
        // markers
        
        let markers = try #require(sessionInfo.markers)
        
        #expect(markers.count == 2)
        
        let marker1 = markers[0]
        #expect(marker1.number == 1)
        #expect(
            marker1.location
                == .timecode(try ProTools.formTimecode(.init(h: 00, m: 59, s: 58, f: 00), at: .fps23_976))
        )
        #expect(marker1.timeReference == .samples(144_144))
        #expect(marker1.name == "Marker 1")
        #expect(marker1.comment == nil)
        #expect(marker1.trackName == "Markers") // default for old txt format
        #expect(marker1.trackType == .ruler) // will always be ruler for old txt format
        
        let marker2 = markers[1]
        #expect(marker2.number == 2)
        #expect(
            marker2.location
                == .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 00, f: 00), at: .fps23_976))
        )
        #expect(marker2.timeReference == .barsAndBeats(bar: 3, beat: 3, ticks: nil))
        #expect(marker2.name == "Marker 2")
        #expect(marker2.comment == "This marker has comments.")
        #expect(marker2.trackName == "Markers") // default for old txt format
        #expect(marker2.trackType == .ruler) // will always be ruler for old txt format
        
        // orphan data
        
        #expect(sessionInfo.orphanData == nil ) // none
    }
}
