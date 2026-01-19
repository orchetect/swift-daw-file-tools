//
//  ProTools SessionText OrphanData.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct ProTools_SessionText_OrphanData {
    @Test
    func sessionText_OrphanData() async throws {
        // load file
        
        let rawData = try TestResource.PTSessionTextExports.unrecognizedSection_23_976fps_DefaultExportOptions_PT2020_3.data()
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        #expect(parseMessages.errors.count == 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // orphan data
        // just test for orphan sections (unrecognized - a hypothetical in case new sections get
        // added to Pro Tools in the future)
        
        #expect(sessionInfo.orphanData?.count == 1)
        
        #expect(
            sessionInfo.orphanData?.first?.heading
                == "U N R E C O G N I Z E D  S E C T I O N"
        )
        #expect(sessionInfo.orphanData?.first?.content == [])
    }
}
