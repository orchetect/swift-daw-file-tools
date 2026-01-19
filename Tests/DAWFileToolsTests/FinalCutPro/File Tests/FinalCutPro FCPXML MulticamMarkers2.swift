//
//  FinalCutPro FCPXML MulticamMarkers2.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_MulticamMarkers2: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.multicamMarkers2.data()
    } }
    
    // MARK: - Tests
    
    @Test
    func parse() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // resources
        // let resources = fcpxml.resources()
        
        // events
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "Test Event")
        #expect(event.element._fcpEffectiveOcclusion() == .notOccluded)
        
        // projects
        let projects = event.projects
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        #expect(project.element._fcpEffectiveOcclusion() == .notOccluded)
        
        // sequence
        let sequence = project.sequence
        #expect(sequence.element._fcpEffectiveOcclusion() == .notOccluded)
        
        // spine
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 1)
        
        // mc-clip
        
        let mcClip = try #require(storyElements[safe: 0]?.fcpAsMCClip)
        #expect(mcClip.ref == "r2")
        #expect(mcClip.lane == nil)
        #expect(mcClip.offsetAsTimecode() == Self.tc("01:00:00:00", .fps23_976))
        #expect(mcClip.offsetAsTimecode()?.frameRate == .fps23_976)
        #expect(mcClip.name == "MC")
        #expect(mcClip.startAsTimecode() == Self.tc("00:00:13:01", .fps23_976))
        #expect(mcClip.durationAsTimecode() == Self.tc("00:00:10:00", .fps23_976))
        #expect(mcClip.durationAsTimecode()?.frameRate == .fps23_976)
        #expect(mcClip.enabled)
        let extractedMCClip = await mcClip.element.fcpExtract()
        #expect(
            extractedMCClip.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:00:00:00", .fps23_976)
        )
        #expect(extractedMCClip.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedMCClip.value(forContext: .effectiveOcclusion) == .notOccluded)
        #expect(extractedMCClip.value(forContext: .localRoles) == [
            .video(raw: "Custom Video Role.Custom Video Role A")!,
            .audio(raw: "music.music-1")!
        ])
        #expect(extractedMCClip.value(forContext: .inheritedRoles) == [
            .inherited(.video(raw: "Custom Video Role.Custom Video Role A")!),
            .inherited(.audio(raw: "music.music-1")!)
        ])
        
        // mc-clip multicam media
        
        let mc = try #require(mcClip.multicamResource)
        
        #expect(mc.format == "r1")
        #expect(mc.tcStartAsTimecode() == Self.tc("00:00:00:00", .fps23_976))
        #expect(mc.angles.count == 6)
        
        // multicam media angles
        
        let mcAngle1 = try #require(mc.angles[safe: 0])
        #expect(mcAngle1.name == "A")
        #expect(mcAngle1.angleID == "+L5xmXXnRXOGdjFq1Eo7EQ")
        #expect(mcAngle1.contents.count == 2)
        
        let mcAngle2 = try #require(mc.angles[safe: 1])
        #expect(mcAngle2.name == "B")
        #expect(mcAngle2.angleID == "FCw5EnkUQcOHu8fwK2TiQQ")
        #expect(mcAngle2.contents.count == 2)
        
        let mcAngle3 = try #require(mc.angles[safe: 2])
        #expect(mcAngle3.name == "C")
        #expect(mcAngle3.angleID == "LphqqelgRX6/pXqi35MoGA")
        #expect(mcAngle3.contents.count == 2)
        
        let mcAngle4 = try #require(mc.angles[safe: 3])
        #expect(mcAngle4.name == "D")
        #expect(mcAngle4.angleID == "gA31yYbYRRSetqQyxAwC8g")
        #expect(mcAngle4.contents.count == 2)
        
        let mcAngle5 = try #require(mc.angles[safe: 4])
        #expect(mcAngle5.name == "Music Angle")
        #expect(mcAngle5.angleID == "9jilYFZRQZ+GI27X4ckxpQ")
        #expect(mcAngle5.contents.count == 1)
        
        let mcAngle6 = try #require(mc.angles[safe: 5])
        #expect(mcAngle6.name == "Sound FX Angle")
        #expect(mcAngle6.angleID == "u6FMsIKMT/eATN52hY2/rA")
        #expect(mcAngle6.contents.count == 2)
        
        // mc-clip marker on main timeline
        
        let mcMarkers = mcClip.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        #expect(mcMarkers.count == 1)
        
        let mcMarker = try #require(mcMarkers[safe: 0])
        #expect(mcMarker.name == "Marker on Multicam Clip")
        let extractedMCMarker = await mcMarker.element.fcpExtract()
        #expect(extractedMCMarker.value(forContext: .absoluteStartAsTimecode()) == Self.tc("01:00:04:08", .fps23_976))
        #expect(extractedMCMarker.value(forContext: .occlusion) == .notOccluded) // within mc-clip
        #expect(extractedMCMarker.value(forContext: .effectiveOcclusion) == .notOccluded) // main timeline
        #expect(extractedMCMarker.value(forContext: .localRoles) == []) // markers never contain roles
        #expect(extractedMCMarker.value(forContext: .inheritedRoles) == [
            .inherited(.video(raw: "Custom Video Role.Custom Video Role A")!),
            .inherited(.audio(raw: "music.music-1")!)
        ])
    }
    
    /// Test main timeline markers extraction with limited occlusion conditions.
    @Test
    func extractMarkers_MainTimeline_LimitedOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(preset: .markers, scope: .mainTimeline)
        #expect(extractedMarkers.count == 1)
        
        #expect(extractedMarkers.map(\.name) == ["Marker on Multicam Clip"])
    }
    
    /// Test main timeline markers extraction with all occlusion conditions.
    @Test
    func extractMarkers_MainTimeline_AllOcclusions_ActiveAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        #expect(extractedMarkers.count == 1)
        
        #expect(extractedMarkers.map(\.name) == ["Marker on Multicam Clip"])
    }
    
    /// Test deep markers extraction with all occlusion conditions and active angles.
    @Test
    func extractMarkers_Deep_AllOcclusions_ActiveAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.deep()
        scope.mcClipAngles = .active
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        // 1 on mc-clip, and 5 with the mc-clip
        #expect(extractedMarkers.count == 1 + 2)
        
        // note these are not sorted chronologically; they're in parsing order
        #expect(extractedMarkers.map(\.name) == [
            "Marker on Multicam Clip", // on mc-clip
            "Marker in Multicam Clip on Angle B", // within mc-clip, video angle
            "Marker in Multicam Clip on Music Angle" // within mc-clip, audio angle
        ])
    }
    
    /// Test deep markers extraction with all occlusion conditions and all angles.
    @Test
    func extractMarkers_Deep_AllOcclusions_AllAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.deep()
        scope.mcClipAngles = .all
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        // 1 on mc-clip, and 5 with the mc-clip
        #expect(extractedMarkers.count == 1 + 5)
        
        // note these are not sorted chronologically; they're in parsing order
        #expect(extractedMarkers.map(\.name) == [
            "Marker on Multicam Clip", // on mc-clip
            "Marker in Multicam Clip on Angle A", // within mc-clip
            "Marker in Multicam Clip on Angle B", // within mc-clip
            "Marker in Multicam Clip on Angle C", // within mc-clip
            "Marker in Multicam Clip on Angle D", // within mc-clip
            "Marker in Multicam Clip on Music Angle" // within mc-clip
        ])
    }
}

#endif
