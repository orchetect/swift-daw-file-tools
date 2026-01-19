//
//  ProTools SessionText Plugins.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_Plugins {
    @Test
    func sessionText_Plugins() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.plugins_23_976fps_DefaultExportOptions_PT2020_3.data()
        
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
        
        // plug-ins
        
        let plugins = try #require(sessionInfo.plugins)
        
        #expect(plugins.count == 15)
        
        #expect(plugins[0].manufacturer == "AIR Music Technology")
        #expect(plugins[0].name == "AIR Kill EQ")
        
        #expect(plugins[1].manufacturer == "AIR Music Technology")
        #expect(plugins[1].name == "AIR Non-Linear Reverb")
        
        #expect(plugins[2].manufacturer == "Avid")
        #expect(plugins[2].name == "Dither")
        
        #expect(plugins[3].manufacturer == "Blue Cat Audio")
        #expect(plugins[3].name == "BCPatchWorkSynth")
        
        #expect(plugins[4].manufacturer == "FabFilter")
        #expect(plugins[4].name == "FabFilter Saturn")
        
        #expect(plugins[5].manufacturer == "FabFilter")
        #expect(plugins[5].name == "FabFilter Timeless 2")
        
        #expect(plugins[6].manufacturer == "Native Instruments")
        #expect(plugins[6].name == "Kontakt")
        
        #expect(plugins[7].manufacturer == "Plogue Art et Technologie, Inc")
        #expect(plugins[7].name == "chipsounds")
        
        #expect(plugins[8].manufacturer == "Plugin Alliance")
        #expect(plugins[8].name == "Schoeps Mono Upmix 1to2")
        
        #expect(plugins[9].manufacturer == "Plugin Alliance")
        #expect(plugins[9].name == "Unfiltered Audio Byome")
        
        #expect(plugins[10].manufacturer == "Plugin Alliance")
        #expect(plugins[10].name == "Vertigo VSM-3")
        
        #expect(plugins[11].manufacturer == "Plugin Alliance")
        #expect(plugins[11].name == "bx_boom")
        
        #expect(plugins[12].manufacturer == "Plugin Alliance")
        #expect(plugins[12].name == "bx_rooMS")
        
        #expect(plugins[13].manufacturer == "accusonus")
        #expect(plugins[13].name == "ERA 4 Voice Leveler")
        
        #expect(plugins[14].manufacturer == "oeksound")
        #expect(plugins[14].name == "soothe2")
    }
}
