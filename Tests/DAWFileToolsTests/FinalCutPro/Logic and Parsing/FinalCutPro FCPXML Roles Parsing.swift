//
//  FinalCutPro FCPXML Roles Parsing.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import Testing

@Suite struct FinalCutPro_FCPXML_RolesParsing: FCPXMLUtilities {
    /// Standard role (audio or video)
    @Test
    func parseRawStandardRole() async throws {
        let parse = FinalCutPro.FCPXML._parseRawStandardRole(rawValue:)
        
        // Should parse
        #expect(try parse("Main").role == "Main")
        #expect(try parse("Main").subRole == nil)
        
        #expect(try parse("Main.Main-1").role == "Main")
        #expect(try parse("Main.Main-1").subRole == "Main-1")
        
        #expect(try parse("Main.Sub").role == "Main")
        #expect(try parse("Main.Sub").subRole == "Sub")
        
        #expect(
            try parse("Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role").role
                == "Hellõ țhiș is ǎ maīn) role 😀"
        )
        #expect(
            try parse("Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role").subRole
                == "This is a 👋 sub role"
        )
        
        // Shouldn't parse
        #expect(throws: (any Error).self) { try parse(".") }
        #expect(throws: (any Error).self) { try parse("..") }
        #expect(throws: (any Error).self) { try parse(".-") }
        #expect(throws: (any Error).self) { try parse(".-1") }
        #expect(throws: (any Error).self) { try parse("Main.") }
        #expect(throws: (any Error).self) { try parse(".Sub") }
        #expect(throws: (any Error).self) { try parse(".Sub-1") }
        #expect(throws: (any Error).self) { try parse("Main.Main.") }
        #expect(throws: (any Error).self) { try parse("Main.Main.Main-1") }
        #expect(throws: (any Error).self) { try parse("iTT?captionFormat=ITT.en") }
        #expect(throws: (any Error).self) { try parse("?=") }
    }
    
    /// Closed caption role
    @Test
    func parseRawCaptionRole() async throws {
        let parse = FinalCutPro.FCPXML._parseRawCaptionRole(rawValue:)
        
        // Should parse
        #expect(try parse("iTT?captionFormat=ITT.en").role == "iTT")
        #expect(try parse("iTT?captionFormat=ITT.en").captionFormat == "ITT.en")
        
        #expect(try parse("Markers?captionFormat=ITT.en").role == "Markers")
        #expect(try parse("Markers?captionFormat=ITT.en").captionFormat == "ITT.en")
        
        #expect(
            try parse("Hellõ țhiș is ǎ capīion role 😀?captionFormat=ITT.en").role
                == "Hellõ țhiș is ǎ capīion role 😀"
        )
        #expect(
            try parse("Hellõ țhiș is ǎ capīion role 😀?captionFormat=ITT.en").captionFormat
                == "ITT.en"
        )
        
        // Shouldn't parse
        #expect(throws: (any Error).self) { try parse("captionFormat=ITT.en") }
        #expect(throws: (any Error).self) { try parse("iTT?captionFormat") }
        #expect(throws: (any Error).self) { try parse("?=") }
        #expect(throws: (any Error).self) { try parse("Main") }
        #expect(throws: (any Error).self) { try parse("Main.Main-1") }
        #expect(throws: (any Error).self) { try parse("Main.Sub") }
        #expect(throws: (any Error).self) { try parse("Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role") }
        #expect(throws: (any Error).self) { try parse(".") }
        #expect(throws: (any Error).self) { try parse("..") }
        #expect(throws: (any Error).self) { try parse(".-") }
        #expect(throws: (any Error).self) { try parse(".-1") }
        #expect(throws: (any Error).self) { try parse("Main.") }
        #expect(throws: (any Error).self) { try parse(".Sub") }
        #expect(throws: (any Error).self) { try parse(".Sub-1") }
        #expect(throws: (any Error).self) { try parse("Main.Main.") }
        #expect(throws: (any Error).self) { try parse("Main.Main.Main") }
    }
    
    @Test
    func collapseStandardSubRole() async {
        let collapse = FinalCutPro.FCPXML._collapseStandardSubRole(role:subRole:)
        
        #expect(collapse("Main", nil).role == "Main")
        #expect(collapse("Main", nil).subRole == nil)
        
        // empty sub-role
        #expect(collapse("Main", "").role == "Main")
        #expect(collapse("Main", "").subRole == nil)
        
        // whitespace-only sub-role
        #expect(collapse("Main", " ").role == "Main")
        #expect(collapse("Main", " ").subRole == nil)
        
        #expect(collapse("Main", "Main-1").role == "Main")
        #expect(collapse("Main", "Main-1").subRole == nil)
        
        #expect(collapse("Main", "Main-20").role == "Main")
        #expect(collapse("Main", "Main-20").subRole == nil)
        
        #expect(collapse("Main", "SubRole").role == "Main")
        #expect(collapse("Main", "SubRole").subRole == "SubRole")
        
        #expect(collapse("Main", "SubRole-20").role == "Main")
        #expect(collapse("Main", "SubRole-20").subRole == "SubRole-20")
    }
    
    @Test
    func isSMainRoleBuiltIn_Video() async {
        typealias VR = FinalCutPro.FCPXML.VideoRole
        
        #expect(!VR(rawValue: "custom")!.isMainRoleBuiltIn)
        #expect(!VR(rawValue: "custom.custom")!.isMainRoleBuiltIn)
        #expect(!VR(rawValue: "custom.custom-1")!.isMainRoleBuiltIn)
        #expect(!VR(rawValue: "custom.video-1")!.isMainRoleBuiltIn)
        
        #expect(VR(rawValue: "video")!.isMainRoleBuiltIn)
        #expect(VR(rawValue: "video.video-1")!.isMainRoleBuiltIn)
        #expect(VR(rawValue: "video.custom")!.isMainRoleBuiltIn)
        
        #expect(VR(rawValue: "Video")!.isMainRoleBuiltIn)
        #expect(VR(rawValue: "Video.Video-1")!.isMainRoleBuiltIn)
        #expect(VR(rawValue: "Video.custom")!.isMainRoleBuiltIn)
        
        #expect(VR(rawValue: "titles")!.isMainRoleBuiltIn)
        #expect(VR(rawValue: "titles.titles-1")!.isMainRoleBuiltIn)
        #expect(VR(rawValue: "titles.custom")!.isMainRoleBuiltIn)
        
        #expect(VR(rawValue: "Titles")!.isMainRoleBuiltIn)
        #expect(VR(rawValue: "Titles.Titles-1")!.isMainRoleBuiltIn)
        #expect(VR(rawValue: "Titles.custom")!.isMainRoleBuiltIn)
    }
    
    @Test
    func isSMainRoleBuiltIn_Audio() async {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        #expect(!AR(rawValue: "custom")!.isMainRoleBuiltIn)
        #expect(!AR(rawValue: "custom.custom")!.isMainRoleBuiltIn)
        #expect(!AR(rawValue: "custom.custom-1")!.isMainRoleBuiltIn)
        #expect(!AR(rawValue: "custom.dialogue-1")!.isMainRoleBuiltIn)
        
        #expect(AR(rawValue: "dialogue")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "dialogue.dialogue-1")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "dialogue.custom")!.isMainRoleBuiltIn)
        
        #expect(AR(rawValue: "Dialogue")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "Dialogue.Dialogue-1")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "Dialogue.custom")!.isMainRoleBuiltIn)
        
        #expect(AR(rawValue: "effects")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "effects.effects-1")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "effects.custom")!.isMainRoleBuiltIn)
        
        #expect(AR(rawValue: "Effects")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "Effects.Effects-1")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "Effects.custom")!.isMainRoleBuiltIn)
        
        #expect(AR(rawValue: "music")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "music.music-1")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "music.custom")!.isMainRoleBuiltIn)
        
        #expect(AR(rawValue: "Music")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "Music.Music-1")!.isMainRoleBuiltIn)
        #expect(AR(rawValue: "Music.custom")!.isMainRoleBuiltIn)
    }
    
    @Test
    func isSMainRoleBuiltIn_Caption() async {
        typealias CR = FinalCutPro.FCPXML.CaptionRole
        
        #expect(!CR(rawValue: "custom?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        #expect(!CR(rawValue: "video?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        #expect(!CR(rawValue: "titles?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        #expect(!CR(rawValue: "dialogue?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        #expect(!CR(rawValue: "effects?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        #expect(!CR(rawValue: "music?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        
        #expect(CR(rawValue: "iTT?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        #expect(CR(rawValue: "SRT?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        #expect(CR(rawValue: "CEA-608?captionFormat=ITT.en")!.isMainRoleBuiltIn)
    }
    
    @Test
    func lowercased() async {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        #expect(AR(rawValue: "dialogue")!.lowercased(derivedOnly: false).rawValue == "dialogue")
        #expect(AR(rawValue: "Dialogue")!.lowercased(derivedOnly: false).rawValue == "dialogue")
        #expect(AR(rawValue: "DIALOGUE")!.lowercased(derivedOnly: false).rawValue == "dialogue")
        
        #expect(AR(rawValue: "dialogue.dialogue-1")!.lowercased(derivedOnly: false).rawValue == "dialogue.dialogue-1")
        #expect(AR(rawValue: "Dialogue.Dialogue-1")!.lowercased(derivedOnly: false).rawValue == "dialogue.dialogue-1")
        #expect(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.lowercased(derivedOnly: false).rawValue == "dialogue.dialogue-1")
        
        #expect(AR(rawValue: "dialogue.mixl")!.lowercased(derivedOnly: false).rawValue == "dialogue.mixl")
        #expect(AR(rawValue: "dialogue.MixL")!.lowercased(derivedOnly: false).rawValue == "dialogue.mixl")
        #expect(AR(rawValue: "Dialogue.MixL")!.lowercased(derivedOnly: false).rawValue == "dialogue.mixl")
        #expect(AR(rawValue: "DIALOGUE.MIXL")!.lowercased(derivedOnly: false).rawValue == "dialogue.mixl")
    }
    
    @Test
    func lowercased_DerivedOnly() async {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        #expect(AR(rawValue: "dialogue")!.lowercased(derivedOnly: true).rawValue == "dialogue")
        #expect(AR(rawValue: "Dialogue")!.lowercased(derivedOnly: true).rawValue == "dialogue")
        #expect(AR(rawValue: "DIALOGUE")!.lowercased(derivedOnly: true).rawValue == "dialogue")
        
        #expect(AR(rawValue: "dialogue.dialogue-1")!.lowercased(derivedOnly: true).rawValue == "dialogue.dialogue-1")
        #expect(AR(rawValue: "Dialogue.Dialogue-1")!.lowercased(derivedOnly: true).rawValue == "dialogue.dialogue-1")
        #expect(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.lowercased(derivedOnly: true).rawValue == "dialogue.dialogue-1")
        
        #expect(AR(rawValue: "dialogue.mixl")!.lowercased(derivedOnly: true).rawValue == "dialogue.mixl")
        #expect(AR(rawValue: "dialogue.MixL")!.lowercased(derivedOnly: true).rawValue == "dialogue.MixL")
        #expect(AR(rawValue: "Dialogue.MixL")!.lowercased(derivedOnly: true).rawValue == "dialogue.MixL")
        #expect(AR(rawValue: "DIALOGUE.MIXL")!.lowercased(derivedOnly: true).rawValue == "dialogue.MIXL")
    }
    
    @Test
    func titleCased() async {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        #expect(AR(rawValue: "dialogue")!.titleCased(derivedOnly: false).rawValue == "Dialogue")
        #expect(AR(rawValue: "Dialogue")!.titleCased(derivedOnly: false).rawValue == "Dialogue")
        #expect(AR(rawValue: "DIALOGUE")!.titleCased(derivedOnly: false).rawValue == "Dialogue")
        
        #expect(AR(rawValue: "dialogue.dialogue-1")!.titleCased(derivedOnly: false).rawValue == "Dialogue.Dialogue-1")
        #expect(AR(rawValue: "Dialogue.Dialogue-1")!.titleCased(derivedOnly: false).rawValue == "Dialogue.Dialogue-1")
        #expect(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.titleCased(derivedOnly: false).rawValue == "Dialogue.Dialogue-1")
        
        #expect(AR(rawValue: "dialogue.mixl")!.titleCased(derivedOnly: false).rawValue == "Dialogue.Mixl")
        #expect(AR(rawValue: "dialogue.MixL")!.titleCased(derivedOnly: false).rawValue == "Dialogue.Mixl") // TODO: not ideal
        #expect(AR(rawValue: "Dialogue.MixL")!.titleCased(derivedOnly: false).rawValue == "Dialogue.Mixl") // TODO: not ideal
        #expect(AR(rawValue: "DIALOGUE.MIXL")!.titleCased(derivedOnly: false).rawValue == "Dialogue.Mixl") // TODO: not ideal
    }
    
    @Test
    func titleCased_DerivedOnly() async {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        #expect(AR(rawValue: "dialogue")!.titleCased(derivedOnly: true).rawValue == "Dialogue")
        #expect(AR(rawValue: "Dialogue")!.titleCased(derivedOnly: true).rawValue == "Dialogue")
        #expect(AR(rawValue: "DIALOGUE")!.titleCased(derivedOnly: true).rawValue == "Dialogue")
        
        #expect(AR(rawValue: "dialogue.dialogue-1")!.titleCased(derivedOnly: true).rawValue == "Dialogue.Dialogue-1")
        #expect(AR(rawValue: "Dialogue.Dialogue-1")!.titleCased(derivedOnly: true).rawValue == "Dialogue.Dialogue-1")
        #expect(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.titleCased(derivedOnly: true).rawValue == "Dialogue.Dialogue-1")
        
        #expect(AR(rawValue: "dialogue.mixl")!.titleCased(derivedOnly: true).rawValue == "Dialogue.mixl")
        #expect(AR(rawValue: "dialogue.MixL")!.titleCased(derivedOnly: true).rawValue == "Dialogue.MixL")
        #expect(AR(rawValue: "Dialogue.MixL")!.titleCased(derivedOnly: true).rawValue == "Dialogue.MixL")
        #expect(AR(rawValue: "DIALOGUE.MIXL")!.titleCased(derivedOnly: true).rawValue == "Dialogue.MIXL")
    }
    
    @Test
    func isSubRoleDerivedFromMainRole() async {
        let isDerived = FinalCutPro.FCPXML._isSubRole(_:derivedFromMainRole:)
        
        #expect(!isDerived(nil, "Dialogue"))
        #expect(!isDerived("", "Dialogue"))
        #expect(!isDerived(" ", "Dialogue"))
        #expect(!isDerived("Dial", "Dialogue"))
        #expect(!isDerived("Video", "Dialogue"))
        
        #expect(isDerived("Dialogue", "Dialogue"))
        #expect(isDerived("Dialogue-1", "Dialogue"))
    }
}

#endif
