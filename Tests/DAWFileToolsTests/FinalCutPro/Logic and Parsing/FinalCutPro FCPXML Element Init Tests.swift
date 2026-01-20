//
//  FinalCutPro FCPXML Element Init Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing

@Suite struct FinalCutPro_FCPXML_ElementInit: FCPXMLUtilities {
    // MARK: - Common Elements
    
    @Test
    func audioChannelSource() async throws {
        let source = FinalCutPro.FCPXML.AudioChannelSource(
            sourceChannels: "1, 2",
            outputChannels: "L, R",
            role: .init(rawValue: "music.music-1")!,
            start: Fraction(3600, 1),
            duration: Fraction(30, 1),
            enabled: false,
            active: false
        )
        
        #expect(source.sourceChannels == "1, 2")
        #expect(source.outputChannels == "L, R")
        #expect(source.role == .init(rawValue: "music.music-1")!)
        #expect(source.start == Fraction(3600, 1))
        #expect(source.duration == Fraction(30, 1))
        #expect(!source.enabled)
        #expect(!source.active)
    }
    
    @Test
    func audioRoleSource() async throws {
        let source = FinalCutPro.FCPXML.AudioRoleSource(
            role: .init(rawValue: "music.music-1")!,
            active: false
        )
        
        #expect(source.role == .init(rawValue: "music.music-1")!)
        #expect(!source.active)
    }
    
    // MARK: - Annotations
    
    @Test
    func caption() async {
        let caption = FinalCutPro.FCPXML.Caption(
            role: .init(rawValue: "iTT?captionFormat=ITT.fr")!,
            note: "Some notes",
            lane: 2,
            offset: Fraction(10, 1),
            name: "Caption name",
            start: Fraction(20, 1),
            duration: Fraction(100, 1),
            enabled: false
        )
        
        #expect(caption.role == .init(rawValue: "iTT?captionFormat=ITT.fr")!)
        #expect(caption.note == "Some notes")
        #expect(caption.lane == 2)
        #expect(caption.offset == Fraction(10, 1))
        #expect(caption.name == "Caption name")
        #expect(caption.start == Fraction(20, 1))
        #expect(caption.duration == Fraction(100, 1))
        #expect(!caption.enabled)
    }
    
    @Test
    func keyword() async {
        let keyword = FinalCutPro.FCPXML.Keyword(
            keywords: ["keyword1", "keyword2"],
            start: Fraction(10, 1),
            duration: Fraction(25, 1),
            note: "Some notes"
        )
        
        #expect(keyword.keywords == ["keyword1", "keyword2"])
        #expect(keyword.note == "Some notes")
        #expect(keyword.start == Fraction(10, 1))
        #expect(keyword.duration == Fraction(25, 1))
    }
    
    @Test
    func marker() async {
        let keyword = FinalCutPro.FCPXML.Marker(
            name: "Marker name",
            configuration: .chapter(posterOffset: Fraction(2, 1)),
            start: Fraction(10, 1),
            duration: Fraction(25, 1),
            note: "Some notes"
        )
        
        #expect(keyword.name == "Marker name")
        #expect(keyword.configuration == .chapter(posterOffset: Fraction(2, 1)))
        #expect(keyword.start == Fraction(10, 1))
        #expect(keyword.duration == Fraction(25, 1))
        #expect(keyword.note == "Some notes")
        
        // extra checks
        #expect(keyword.element.fcpPosterOffset == Fraction(2, 1))
    }
    
    // MARK: - Clips
    
    @Test
    mutating func assetClip() async {
        let assetClip = FinalCutPro.FCPXML.AssetClip(
            ref: "r2",
            srcEnable: .audio,
            format: "r3",
            tcStart: Fraction(3600, 1),
            tcFormat: .dropFrame,
            audioRole: .init(rawValue: "music.music-1")!,
            videoRole: .init(rawValue: "video.video-1")!,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        #expect(assetClip.ref == "r2")
        #expect(assetClip.srcEnable == .audio)
        #expect(assetClip.format == "r3")
        #expect(assetClip.tcStart == Fraction(3600, 1))
        #expect(assetClip.tcFormat == .dropFrame)
        #expect(assetClip.audioRole == .init(rawValue: "music.music-1")!)
        #expect(assetClip.videoRole == .init(rawValue: "video.video-1")!)
        #expect(assetClip.audioStart == Fraction(10, 1))
        #expect(assetClip.audioDuration == Fraction(20, 1))
        #expect(assetClip.lane == 2)
        #expect(assetClip.offset == Fraction(4, 1))
        #expect(assetClip.name == "Clip name")
        #expect(assetClip.start == Fraction(2, 1))
        #expect(assetClip.duration == Fraction(100, 1))
        #expect(!assetClip.enabled)
        #expect(assetClip.modDate == "2022-12-30 20:47:39 -0800")
        #expect(assetClip.note == "Notes here")
        #expect(assetClip.metadata == metadata)
    }
    
    @Test
    func audio() async {
        let audio = FinalCutPro.FCPXML.Audio(
            ref: "r2",
            role: .init(rawValue: "music.music-1")!,
            srcID: "3",
            sourceChannels: "3, 4",
            outputChannels: "L, R",
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            note: "Notes here"
        )
        
        #expect(audio.ref == "r2")
        #expect(audio.role == .init(rawValue: "music.music-1")!)
        #expect(audio.srcID == "3")
        #expect(audio.sourceChannels == "3, 4")
        #expect(audio.outputChannels == "L, R")
        #expect(audio.lane == 2)
        #expect(audio.offset == Fraction(4, 1))
        #expect(audio.name == "Clip name")
        #expect(audio.start == Fraction(2, 1))
        #expect(audio.duration == Fraction(100, 1))
        #expect(!audio.enabled)
        #expect(audio.note == "Notes here")
    }
    
    @Test
    func audition() async {
        let audition = FinalCutPro.FCPXML.Audition(
            lane: 2,
            offset: Fraction(4, 1),
            modDate: "2022-12-30 20:47:39 -0800"
        )
        
        #expect(audition.lane == 2)
        #expect(audition.offset == Fraction(4, 1))
        #expect(audition.modDate == "2022-12-30 20:47:39 -0800")
    }
    
    @Test
    mutating func clip() async {
        let clip = FinalCutPro.FCPXML.Clip(
            format: "r3",
            tcStart: Fraction(3600, 1),
            tcFormat: .dropFrame,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        #expect(clip.format == "r3")
        #expect(clip.tcStart == Fraction(3600, 1))
        #expect(clip.tcFormat == .dropFrame)
        #expect(clip.audioStart == Fraction(10, 1))
        #expect(clip.audioDuration == Fraction(20, 1))
        #expect(clip.lane == 2)
        #expect(clip.offset == Fraction(4, 1))
        #expect(clip.name == "Clip name")
        #expect(clip.start == Fraction(2, 1))
        #expect(clip.duration == Fraction(100, 1))
        #expect(!clip.enabled)
        #expect(clip.modDate == "2022-12-30 20:47:39 -0800")
        #expect(clip.note == "Notes here")
        #expect(clip.metadata == metadata)
    }
    
    @Test
    mutating func gap() async {
        let gap = FinalCutPro.FCPXML.Gap(
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            note: "Notes here",
            metadata: metadata
        )
        
        #expect(gap.offset == Fraction(4, 1))
        #expect(gap.name == "Clip name")
        #expect(gap.start == Fraction(2, 1))
        #expect(gap.duration == Fraction(100, 1))
        #expect(!gap.enabled)
        #expect(gap.note == "Notes here")
        #expect(gap.metadata == metadata)
    }
    
    @Test
    mutating func mcClip() async {
        let mcClip = FinalCutPro.FCPXML.MCClip(
            ref: "r2",
            srcEnable: .audio,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        #expect(mcClip.ref == "r2")
        #expect(mcClip.srcEnable == .audio)
        #expect(mcClip.audioStart == Fraction(10, 1))
        #expect(mcClip.audioDuration == Fraction(20, 1))
        #expect(mcClip.lane == 2)
        #expect(mcClip.offset == Fraction(4, 1))
        #expect(mcClip.name == "Clip name")
        #expect(mcClip.start == Fraction(2, 1))
        #expect(mcClip.duration == Fraction(100, 1))
        #expect(!mcClip.enabled)
        #expect(mcClip.modDate == "2022-12-30 20:47:39 -0800")
        #expect(mcClip.note == "Notes here")
        #expect(mcClip.metadata == metadata)
    }
    
    @Test
    func multicamSource() async {
        let mcSource = FinalCutPro.FCPXML.MulticamSource(
            angleID: "as9dn8oadnof",
            sourceEnable: .video
        )
        
        #expect(mcSource.angleID == "as9dn8oadnof")
        #expect(mcSource.sourceEnable == .video)
    }
    
    @Test
    mutating func refClip() async {
        let refClip = FinalCutPro.FCPXML.RefClip(
            ref: "r2",
            srcEnable: .audio,
            useAudioSubroles: true,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        #expect(refClip.ref == "r2")
        #expect(refClip.srcEnable == .audio)
        #expect(refClip.useAudioSubroles)
        #expect(refClip.audioStart == Fraction(10, 1))
        #expect(refClip.audioDuration == Fraction(20, 1))
        #expect(refClip.lane == 2)
        #expect(refClip.offset == Fraction(4, 1))
        #expect(refClip.name == "Clip name")
        #expect(refClip.start == Fraction(2, 1))
        #expect(refClip.duration == Fraction(100, 1))
        #expect(!refClip.enabled)
        #expect(refClip.modDate == "2022-12-30 20:47:39 -0800")
        #expect(refClip.note == "Notes here")
        #expect(refClip.metadata == metadata)
    }
    
    @Test
    mutating func syncClip() async {
        let syncClip = FinalCutPro.FCPXML.SyncClip(
            format: "r2",
            tcStart: Fraction(3600, 1),
            tcFormat: .dropFrame,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        #expect(syncClip.format == "r2")
        #expect(syncClip.tcStart == Fraction(3600, 1))
        #expect(syncClip.tcFormat == .dropFrame)
        #expect(syncClip.audioStart == Fraction(10, 1))
        #expect(syncClip.audioDuration == Fraction(20, 1))
        #expect(syncClip.lane == 2)
        #expect(syncClip.offset == Fraction(4, 1))
        #expect(syncClip.name == "Clip name")
        #expect(syncClip.start == Fraction(2, 1))
        #expect(syncClip.duration == Fraction(100, 1))
        #expect(!syncClip.enabled)
        #expect(syncClip.modDate == "2022-12-30 20:47:39 -0800")
        #expect(syncClip.note == "Notes here")
        #expect(syncClip.metadata == metadata)
    }
    
    @Test
    func syncSource() async {
        let syncSource = FinalCutPro.FCPXML.SyncClip.SyncSource(
            sourceID: .connected
        )
        
        #expect(syncSource.sourceID == .connected)
    }
    
    @Test
    mutating func title() async {
        let title = FinalCutPro.FCPXML.Title(
            ref: "r2",
            role: .init(rawValue: "video.video-1")!,
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            note: "Notes here",
            metadata: metadata
        )
        
        #expect(title.ref == "r2")
        #expect(title.role == .init(rawValue: "video.video-1")!)
        #expect(title.lane == 2)
        #expect(title.offset == Fraction(4, 1))
        #expect(title.name == "Clip name")
        #expect(title.start == Fraction(2, 1))
        #expect(title.duration == Fraction(100, 1))
        #expect(!title.enabled)
        #expect(title.note == "Notes here")
        #expect(title.metadata == metadata)
    }
    
    @Test
    mutating func transition() async {
        let transition = FinalCutPro.FCPXML.Transition(
            offset: Fraction(3600, 1),
            name: "Some Transition",
            duration: Fraction(4, 1),
            metadata: metadata
        )
        
        #expect(transition.offset == Fraction(3600, 1))
        #expect(transition.name == "Some Transition")
        #expect(transition.duration == Fraction(4, 1))
        #expect(transition.metadata == metadata)
    }
    
    @Test
    func video() async {
        let title = FinalCutPro.FCPXML.Video(
            ref: "r2",
            role: .init(rawValue: "video.video-1")!,
            srcID: "3",
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            note: "Notes here"
        )
        
        #expect(title.ref == "r2")
        #expect(title.role == .init(rawValue: "video.video-1")!)
        #expect(title.srcID == "3")
        #expect(title.lane == 2)
        #expect(title.offset == Fraction(4, 1))
        #expect(title.name == "Clip name")
        #expect(title.start == Fraction(2, 1))
        #expect(title.duration == Fraction(100, 1))
        #expect(!title.enabled)
        #expect(title.note == "Notes here")
    }
    
    // MARK: - Story
    
    @Test
    mutating func sequence() async throws {
        let sequence = FinalCutPro.FCPXML.Sequence(
            spine: spine,
            audioLayout: .stereo,
            audioRate: .rate48kHz,
            renderFormat: "fmt",
            keywords: "keyword1,keyword2",
            format: "r2",
            duration: Fraction(100, 1),
            tcStart: Fraction(3600, 1),
            tcFormat: .dropFrame,
            note: "Some notes",
            metadata: metadata
        )
        
        #expect(sequence.spine == spine)
        #expect(sequence.audioLayout == .stereo)
        #expect(sequence.audioRate == .rate48kHz)
        #expect(sequence.renderFormat == "fmt")
        #expect(sequence.keywords == "keyword1,keyword2")
        #expect(sequence.format == "r2")
        #expect(sequence.duration == Fraction(100, 1))
        #expect(sequence.tcStart == Fraction(3600, 1))
        #expect(sequence.tcFormat == .dropFrame)
        #expect(sequence.note == "Some notes")
        #expect(sequence.metadata == metadata)
    }
    
    let spine = FinalCutPro.FCPXML.Spine(
        name: "Spine name",
        format: "r2",
        lane: 2,
        offset: Fraction(4, 1)
    )
    
    @Test
    func spine() async {
        #expect(spine.name == "Spine name")
        #expect(spine.format == "r2")
        #expect(spine.lane == 2)
        #expect(spine.offset == Fraction(4, 1))
    }
                                         
    // MARK: - Resources
    
    let mediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: .originalMedia,
        sig: "978BD3B254D68A6FA69E87D0D90544FD",
        src: URL(string: "file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Is%20This%20The%20Land%20of%20Fire%20or%20Ice.mp4")!,
        bookmark: "Ym9va5QEAAAAAAQQMAAAAFVzgSnK8/ycBhhs90R/FSAWmWSsEtn07NRJDmX1V9MVtAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAACMAAAABAQAASXMgVGhpcyBUaGUgTGFuZCBvZiBGaXJlIG9yIEljZS5tcDQAIAAAAAEGAAAQAAAAIAAAADQAAABEAAAAVAAAAGwAAAB4AAAAiAAAAAgAAAAEAwAAIwAAAAAAAAAIAAAABAMAAAIAAAAAAAAACAAAAAQDAADkAAAAAAAAAAgAAAAEAwAA6AAAAAAAAAAIAAAABAMAAMVPAQAAAAAACAAAAAQDAAB0UAEAAAAAAAgAAAAEAwAAi1ABAAAAAAAIAAAABAMAAJxTAQAAAAAAIAAAAAEGAADcAAAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAAgAAAAABAAAQcRNZNcAAAAYAAAAAQIAAAEAAAAAAAAADwAAAAAAAAAAAAAAAAAAABoAAAABCQAAZmlsZTovLy9Wb2x1bWVzL1dvcmtzcGFjZS8AAAgAAAAEAwAAAMBa1OgAAAAIAAAAAAQAAEHEzixfQGbMJAAAAAEBAAA0QTEzQkU5NS1GN0Y2LTRBRUYtQjUzRC1FQjdDODFGREQ1OEQYAAAAAQIAAAEBAAABAAAA7xMAAAEAAAAAAAAAAAAAABIAAAABAQAAL1ZvbHVtZXMvV29ya3NwYWNlAAAIAAAAAQkAAGZpbGU6Ly8vDAAAAAEBAABNYWNpbnRvc2ggSEQIAAAABAMAAADgAePoAAAACAAAAAAEAABBxXou9AAAACQAAAABAQAANTY4QUU1RjEtMzg1Ny00M0Q0LUIyOEMtNDcyRUQ1QjNDODYwGAAAAAECAACBAAAAAQAAAO8TAAABAAAAAAAAAAAAAAABAAAAAQEAAC8AAABgAAAA/v///wDwAAAAAAAABwAAAAIgAADwAgAAAAAAAAUgAABgAgAAAAAAABAgAABwAgAAAAAAABEgAACkAgAAAAAAABIgAACEAgAAAAAAABMgAACUAgAAAAAAACAgAADQAgAAAAAAAAQAAAADAwAAAPAAAAQAAAADAwAAAAAAAAQAAAADAwAAAQAAACQAAAABBgAAZAMAAHADAAB8AwAAcAMAAHADAABwAwAAcAMAAHADAABwAwAAqAAAAP7///8BAAAA/AIAAA0AAAAEEAAAtAAAAAAAAAAFEAAAXAEAAAAAAAAQEAAAlAEAAAAAAABAEAAAhAEAAAAAAAAAIAAAiAMAAAAAAAACIAAARAIAAAAAAAAFIAAAtAEAAAAAAAAQIAAAIAAAAAAAAAARIAAA+AEAAAAAAAASIAAA2AEAAAAAAAATIAAA6AEAAAAAAAAgIAAAJAIAAAAAAAAQ0AAABAAAAAAAAAA="
    )
    
    @Test
    func mediaRep() async throws {
        #expect(mediaRep.kind == .originalMedia)
        #expect(mediaRep.sig == "978BD3B254D68A6FA69E87D0D90544FD")
        #expect(
            mediaRep.src
                == URL(string: "file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Is%20This%20The%20Land%20of%20Fire%20or%20Ice.mp4")!
        )
        #expect(
            mediaRep.bookmarkData
                == "Ym9va5QEAAAAAAQQMAAAAFVzgSnK8/ycBhhs90R/FSAWmWSsEtn07NRJDmX1V9MVtAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAACMAAAABAQAASXMgVGhpcyBUaGUgTGFuZCBvZiBGaXJlIG9yIEljZS5tcDQAIAAAAAEGAAAQAAAAIAAAADQAAABEAAAAVAAAAGwAAAB4AAAAiAAAAAgAAAAEAwAAIwAAAAAAAAAIAAAABAMAAAIAAAAAAAAACAAAAAQDAADkAAAAAAAAAAgAAAAEAwAA6AAAAAAAAAAIAAAABAMAAMVPAQAAAAAACAAAAAQDAAB0UAEAAAAAAAgAAAAEAwAAi1ABAAAAAAAIAAAABAMAAJxTAQAAAAAAIAAAAAEGAADcAAAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAAgAAAAABAAAQcRNZNcAAAAYAAAAAQIAAAEAAAAAAAAADwAAAAAAAAAAAAAAAAAAABoAAAABCQAAZmlsZTovLy9Wb2x1bWVzL1dvcmtzcGFjZS8AAAgAAAAEAwAAAMBa1OgAAAAIAAAAAAQAAEHEzixfQGbMJAAAAAEBAAA0QTEzQkU5NS1GN0Y2LTRBRUYtQjUzRC1FQjdDODFGREQ1OEQYAAAAAQIAAAEBAAABAAAA7xMAAAEAAAAAAAAAAAAAABIAAAABAQAAL1ZvbHVtZXMvV29ya3NwYWNlAAAIAAAAAQkAAGZpbGU6Ly8vDAAAAAEBAABNYWNpbnRvc2ggSEQIAAAABAMAAADgAePoAAAACAAAAAAEAABBxXou9AAAACQAAAABAQAANTY4QUU1RjEtMzg1Ny00M0Q0LUIyOEMtNDcyRUQ1QjNDODYwGAAAAAECAACBAAAAAQAAAO8TAAABAAAAAAAAAAAAAAABAAAAAQEAAC8AAABgAAAA/v///wDwAAAAAAAABwAAAAIgAADwAgAAAAAAAAUgAABgAgAAAAAAABAgAABwAgAAAAAAABEgAACkAgAAAAAAABIgAACEAgAAAAAAABMgAACUAgAAAAAAACAgAADQAgAAAAAAAAQAAAADAwAAAPAAAAQAAAADAwAAAAAAAAQAAAADAwAAAQAAACQAAAABBgAAZAMAAHADAAB8AwAAcAMAAHADAABwAwAAcAMAAHADAABwAwAAqAAAAP7///8BAAAA/AIAAA0AAAAEEAAAtAAAAAAAAAAFEAAAXAEAAAAAAAAQEAAAlAEAAAAAAABAEAAAhAEAAAAAAAAAIAAAiAMAAAAAAAACIAAARAIAAAAAAAAFIAAAtAEAAAAAAAAQIAAAIAAAAAAAAAARIAAA+AEAAAAAAAASIAAA2AEAAAAAAAATIAAA6AEAAAAAAAAgIAAAJAIAAAAAAAAQ0AAABAAAAAAAAAA="
                .data(using: .utf8)!
        )
    }
    
    // TODO: replace with parameterized init once it's implemented on Metadata model
    let metadataXML = try! XMLElement(xmlString: """
            <metadata>
                <md key="com.apple.proapps.mio.cameraName" value="TestVideo Camera Name"/>
                <md key="com.apple.proapps.studio.rawToLogConversion" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemProfileName" value="SD (6-1-6)"/>
                <md key="com.apple.proapps.studio.cameraISO" value="120"/>
                <md key="com.apple.proapps.studio.cameraColorTemperature" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemCodecs">
                    <array>
                        <string>'avc1'</string>
                        <string>MPEG-4 AAC</string>
                    </array>
                </md>
                <md key="com.apple.proapps.mio.ingestDate" value="2023-01-01 19:46:28 -0800"/>
                
                <md key="com.apple.proapps.studio.reel" value="TestVideo Reel"/>
                <md key="com.apple.proapps.studio.scene" value="TestVideo Scene"/>
                <md key="com.apple.proapps.studio.shot" value="TestVideo Take"/>
                <md key="com.apple.proapps.studio.angle" value="TestVideo Camera Angle"/>
            </metadata>
            """
    )
    lazy var metadata = FinalCutPro.FCPXML.Metadata(element: metadataXML)!
    
    @Test
    func metadata() async throws {
        let md = FinalCutPro.FCPXML.Metadata()
        
        // test initial state
        #expect(md.cameraName == nil)
        #expect(md.rawToLogConversion == nil)
        #expect(md.colorProfile == nil)
        #expect(md.cameraISO == nil)
        #expect(md.cameraColorTemperature == nil)
        #expect(md.codecs == nil)
        #expect(md.ingestDate == nil)
        #expect(md.reel == nil)
        #expect(md.scene == nil)
        #expect(md.take == nil)
        #expect(md.cameraAngle == nil)
        
        // set new values
        md.cameraName = "TestVideo Camera Name"
        md.rawToLogConversion = "0"
        md.colorProfile = "SD (6-1-6)"
        md.cameraISO = "120"
        md.cameraColorTemperature = "0"
        md.codecs = ["'avc1'", "MPEG-4 AAC"]
        md.ingestDate = "2023-01-01 19:46:28 -0800"
        md.reel = "TestVideo Reel"
        md.scene = "TestVideo Scene"
        md.take = "TestVideo Take"
        md.cameraAngle = "TestVideo Camera Angle"
        
        // test new values
        #expect(md.cameraName == "TestVideo Camera Name")
        #expect(md.rawToLogConversion == "0")
        #expect(md.colorProfile == "SD (6-1-6)")
        #expect(md.cameraISO == "120")
        #expect(md.cameraColorTemperature == "0")
        #expect(md.codecs == ["'avc1'", "MPEG-4 AAC"])
        #expect(md.ingestDate == "2023-01-01 19:46:28 -0800")
        #expect(md.reel == "TestVideo Reel")
        #expect(md.scene == "TestVideo Scene")
        #expect(md.take == "TestVideo Take")
        #expect(md.cameraAngle == "TestVideo Camera Angle")
        
        // remove values
        md.cameraName = nil
        md.rawToLogConversion = nil
        md.colorProfile = nil
        md.cameraISO = nil
        md.cameraColorTemperature = nil
        md.codecs = nil
        md.ingestDate = nil
        md.reel = nil
        md.scene = nil
        md.take = nil
        md.cameraAngle = nil
        
        // test removed values
        #expect(md.cameraName == nil)
        #expect(md.rawToLogConversion == nil)
        #expect(md.colorProfile == nil)
        #expect(md.cameraISO == nil)
        #expect(md.cameraColorTemperature == nil)
        #expect(md.codecs == nil)
        #expect(md.ingestDate == nil)
        #expect(md.reel == nil)
        #expect(md.scene == nil)
        #expect(md.take == nil)
        #expect(md.cameraAngle == nil)
        
        // check codecs with empty array; should remove key entirely.
        md.codecs = []
        #expect(md.codecs == nil)
    }
    
    @Test
    mutating func metadata_FromXML() async throws {
        let metadata = metadata
        
        #expect(metadata.cameraName == "TestVideo Camera Name")
        #expect(metadata.rawToLogConversion == "0") // TODO: should be `Bool` instead of `String`?
        #expect(metadata.colorProfile == "SD (6-1-6)")
        #expect(metadata.cameraISO == "120")
        #expect(metadata.cameraColorTemperature == "0")
        #expect(metadata.codecs == ["'avc1'", "MPEG-4 AAC"])
        #expect(metadata.ingestDate == "2023-01-01 19:46:28 -0800")
        #expect(metadata.reel == "TestVideo Reel")
        #expect(metadata.scene == "TestVideo Scene")
        #expect(metadata.take == "TestVideo Take")
        #expect(metadata.cameraAngle == "TestVideo Camera Angle")
    }
    
    @Test
    func metadatum() async throws {
        let metadatum = FinalCutPro.FCPXML.Metadata.Metadatum()
        
        metadatum.key = .ingestDate
        #expect(metadatum.key == .ingestDate)
        
        metadatum.keyString = "com.domain.some.key"
        #expect(metadatum.keyString == "com.domain.some.key")
        #expect(metadatum.key == nil) // will be nil since the key isn't recognized
        
        metadatum.value = "Value String"
        #expect(metadatum.value == "Value String")
        
        metadatum.editable = true
        #expect(metadatum.editable)
        
        metadatum.type = .timecode
        #expect(metadatum.type == .timecode)
        
        metadatum.displayName = "Some MD Name"
        #expect(metadatum.displayName == "Some MD Name")
        
        metadatum.displayDescription = "Description of some MD."
        #expect(metadatum.displayDescription == "Description of some MD.")
    }
    
    @Test
    mutating func asset() async throws {
        let asset = FinalCutPro.FCPXML.Asset(
            id: "r5",
            name: "Is This The Land of Fire or Ice",
            start: .zero,
            duration: Fraction(205800, 1000),
            format: "r1",
            uid: "978BD3B254D68A6FA69E87D0D90544FD",
            hasAudio: true,
            hasVideo: true,
            audioSources: 1,
            audioChannels: 2,
            audioRate: .rate44_1kHz,
            videoSources: 1,
            auxVideoFlags: "flags",
            mediaRep: mediaRep,
            metadata: metadata
        )
        
        #expect(asset.id == "r5")
        #expect(asset.name == "Is This The Land of Fire or Ice")
        #expect(asset.start == .zero)
        #expect(asset.duration == Fraction(205800, 1000))
        #expect(asset.format == "r1")
        #expect(asset.uid == "978BD3B254D68A6FA69E87D0D90544FD")
        #expect(asset.hasAudio)
        #expect(asset.hasVideo)
        #expect(asset.audioSources == 1)
        #expect(asset.audioChannels == 2)
        #expect(asset.audioRate == .rate44_1kHz)
        #expect(asset.videoSources == 1)
        #expect(asset.auxVideoFlags == "flags")
        #expect(asset.mediaRep == mediaRep)
        #expect(asset.metadata == metadata)
    }
    
    @Test
    func effect() async {
        let effect = FinalCutPro.FCPXML.Effect(
            id: "r6",
            name: "Basic Title",
            uid: ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti",
            src: "source"
        )
        
        #expect(effect.id == "r6")
        #expect(effect.name == "Basic Title")
        #expect(effect.uid == ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti")
        #expect(effect.src == "source")
    }
    
    @Test
    func format() async {
        let format = FinalCutPro.FCPXML.Format(
            id: "r1",
            name: "FFVideoFormat1080p25",
            frameDuration: Fraction(200, 5000),
            fieldOrder: nil,
            width: 1920,
            height: 1080,
            paspH: nil,
            paspV: nil,
            colorSpace: "1-1-1 (Rec. 709)",
            projection: nil,
            stereoscopic: nil
        )
        
        #expect(format.id == "r1")
        #expect(format.name == "FFVideoFormat1080p25")
        #expect(format.frameDuration == Fraction(200, 5000))
        #expect(format.fieldOrder == nil)
        #expect(format.width == 1920)
        #expect(format.height == 1080)
        #expect(format.paspH == nil)
        #expect(format.paspV == nil)
        #expect(format.colorSpace == "1-1-1 (Rec. 709)")
        #expect(format.projection == nil)
        #expect(format.stereoscopic == nil)
    }
    
    @Test
    func locator() async {
        let locator = FinalCutPro.FCPXML.Locator(
            id: "blah",
            url: URL(string: "file:///Users/user/movie.mov")!
        )
        
        #expect(locator.id == "blah")
        #expect(locator.url == URL(string: "file:///Users/user/movie.mov")!)
    }
    
    @Test
    func media() async {
        let media = FinalCutPro.FCPXML.Media(
            id: "r2",
            name: "Some Media",
            uid: "9asdfyna9d8fnyads8",
            projectRef: "Project reference ahoy",
            modDate: "2022-12-30 20:47:39 -0800"
        )
        
        #expect(media.id == "r2")
        #expect(media.name == "Some Media")
        #expect(media.uid == "9asdfyna9d8fnyads8")
        #expect(media.projectRef == "Project reference ahoy")
        #expect(media.modDate == "2022-12-30 20:47:39 -0800")
    }
    
    @Test
    func objectTracker() async {
        // TODO: write unit test
        
        let tracker = FinalCutPro.FCPXML.ObjectTracker(trackingShapes: [
            .init(),
            .init()
        ])
        
        // TODO: add equality check for tracking shapes once properties have been implemented for them
        // for now, just check that child count is correct
        #expect(tracker.trackingShapes.count == 2)
    }
    
    // MARK: - Textual
    
    @Test
    func text() async {
        let text = FinalCutPro.FCPXML.Text(
            displayStyle: .rollUp,
            rollUpHeight: "20",
            position: "50 200",
            placement: .left,
            alignment: .right
        )
        
        #expect(text.displayStyle == .rollUp)
        #expect(text.rollUpHeight == "20")
        #expect(text.position == "50 200")
        #expect(text.placement == .left)
        #expect(text.alignment == .right)
    }
    
    // MARK: - Structure
    
    @Test
    func library() async throws {
        let url = try #require(URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/"))
        
        let library = FinalCutPro.FCPXML.Library(
            location: url
        )
        
        #expect(library.location == url)
    }
    
    @Test
    func event() async {
        let event = FinalCutPro.FCPXML.Event(
            name: "Event name",
            uid: "a98msduf8masdu8f"
        )
        
        #expect(event.name == "Event name")
        #expect(event.uid == "a98msduf8masdu8f")
    }
    
    @Test
    func project() async {
        let project = FinalCutPro.FCPXML.Project(
            name: "Project name",
            id: "asd8fn08n",
            uid: "js9ajdf9dj",
            modDate: "2022-12-30 20:47:39 -0800"
        )
        
        #expect(project.name == "Project name")
        #expect(project.id == "asd8fn08n")
        #expect(project.uid == "js9ajdf9dj")
        #expect(project.modDate == "2022-12-30 20:47:39 -0800")
    }
    
    // MARK: - Misc.
    
    @Test
    func conformRateA() async {
        let conformRate = FinalCutPro.FCPXML.ConformRate(
            scaleEnabled: true,
            srcFrameRate: .fps24,
            frameSampling: .frameBlending
        )
        
        #expect(conformRate.scaleEnabled)
        #expect(conformRate.srcFrameRate == .fps24)
        #expect(conformRate.frameSampling == .frameBlending)
    }
    
    @Test
    func conformRateB() async {
        let conformRate = FinalCutPro.FCPXML.ConformRate(
            scaleEnabled: false,
            srcFrameRate: nil,
            frameSampling: .floor
        )
        
        #expect(!conformRate.scaleEnabled)
        #expect(conformRate.srcFrameRate == nil)
        #expect(conformRate.frameSampling == .floor)
    }
    
    @Test
    func timeMapA() async {
        let timeMap = FinalCutPro.FCPXML.TimeMap(
            frameSampling: .nearestNeighbor,
            preservesPitch: false
        )
        
        #expect(timeMap.frameSampling == .nearestNeighbor)
        #expect(!timeMap.preservesPitch)
        
        let readTimePoints = Array(timeMap.timePoints)
        #expect(readTimePoints.count == 0)
    }
    
    @Test
    func timeMapB() async {
        let timePoints: [FinalCutPro.FCPXML.TimeMap.TimePoint] = [timePoint]
        
        let timeMap = FinalCutPro.FCPXML.TimeMap(
            frameSampling: .floor,
            preservesPitch: true,
            timePoints: timePoints
        )
        
        #expect(timeMap.frameSampling == .floor)
        #expect(timeMap.preservesPitch)
        
        let readTimePoints = Array(timeMap.timePoints)
        #expect(readTimePoints.count == 1)
        #expect(readTimePoints == timePoints)
    }
    
    let timePoint = FinalCutPro.FCPXML.TimeMap.TimePoint(
        time: Fraction(2, 1),
        originalTime: Fraction(1, 1),
        interpolation: .linear,
        transitionInTime: Fraction(3, 1),
        transitionOutTime: Fraction(4, 1)
    )
    
    @Test
    func timePoint() async {
        #expect(timePoint.time == Fraction(2, 1))
        #expect(timePoint.originalTime == Fraction(1, 1))
        #expect(timePoint.interpolation == .linear)
        #expect(timePoint.transitionInTime == Fraction(3, 1))
        #expect(timePoint.transitionOutTime == Fraction(4, 1))
    }
}

#endif
